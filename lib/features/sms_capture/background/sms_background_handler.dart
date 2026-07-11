import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_refresh.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/sms_capture/background/sms_capture_runtime.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_debug_log.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_sync_service.dart';

const _backgroundChannelName = 'com.spendsense.spendsense/sms_background';
const _readyChannelName = 'com.spendsense.spendsense/sms_background_ready';

@pragma('vm:entry-point')
void smsBackgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  smsDebugLog('smsBackgroundMain entrypoint starting');
  SmsBackgroundHandler.install();
}

class SmsBackgroundHandler {
  static void install() {
    const backgroundChannel = MethodChannel(_backgroundChannelName);
    const readyChannel = MethodChannel(_readyChannelName);

    backgroundChannel.setMethodCallHandler((call) async {
      smsDebugLog('background method=${call.method}');
      switch (call.method) {
        case 'processSms':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final receivedAtMs = (args['receivedAtMs'] as num).toInt();
          return processIncomingSms(
            body: args['body'] as String,
            receivedAtMs: receivedAtMs,
            sender: args['sender'] as String?,
          );
        case 'syncInbox':
          return syncInbox();
        default:
          throw PlatformException(
            code: 'not_implemented',
            message: 'Unknown method ${call.method}',
          );
      }
    });

    readyChannel.invokeMethod<void>('ready');
    smsDebugLog('background handler installed; ready signaled');
  }

  static Future<Map<String, Object?>> processIncomingSms({
    required String body,
    required int receivedAtMs,
    String? sender,
  }) async {
    smsDebugLog(
      'processIncomingSms sender=$sender bodyLen=${body.length} '
      'receivedAtMs=$receivedAtMs',
    );

    final probeDatabase = AppDatabase();
    try {
      final settings = OnboardingRepository(probeDatabase);
      final onboardingDone = await settings.isOnboardingComplete();
      final importDone = await settings.importCompleted();
      smsDebugLog(
        'gate onboarding=$onboardingDone importCompleted=$importDone',
      );
      if (!onboardingDone) {
        return _resultMap(SmsCaptureResult.ignored);
      }

      if (!importDone) {
        return _resultMap(SmsCaptureResult.ignored);
      }
    } finally {
      await probeDatabase.close();
    }

    final runtime = await SmsCaptureRuntime.open();
    final settings = OnboardingRepository(runtime.database);

    final result = await runtime.service.processSms(body);
    smsDebugLog('processIncomingSms result=${result.name}');
    if (result == SmsCaptureResult.captured ||
        result == SmsCaptureResult.duplicate) {
      final receivedAt = DateTime.fromMillisecondsSinceEpoch(receivedAtMs);
      final lastSync = await settings.lastSmsSyncAt();
      if (lastSync == null || receivedAt.isAfter(lastSync)) {
        await settings.saveLastSmsSyncAt(receivedAt);
        smsDebugLog('advanced lastSmsSyncAt -> $receivedAt');
      }
    }

    if (result == SmsCaptureResult.captured) {
      await _refreshHomeWidgets(runtime.database);
    }

    return _resultMap(result);
  }

  static Future<Map<String, Object?>> syncInbox() async {
    smsDebugLog('syncInbox start');
    final runtime = await SmsCaptureRuntime.open();
    final settings = OnboardingRepository(runtime.database);
    final service = SmsSyncService(
      inbox: PlatformSmsInboxGateway(),
      captureService: runtime.service,
      settings: settings,
      permissionGateway: PermissionHandlerSmsGateway(),
    );

    try {
      final result = await service.syncNewMessages();
      final capturedCount = switch (result) {
        ProcessedSmsSyncResult(:final capturedCount) => capturedCount,
        _ => 0,
      };
      if (capturedCount > 0) {
        await _refreshHomeWidgets(runtime.database);
      }
      return switch (result) {
        SkippedSmsSyncResult(:final reason) => {
            'status': 'skipped',
            'reason': reason.name,
          },
        ProcessedSmsSyncResult(
          :final messageCount,
          :final capturedCount,
          :final duplicateCount,
          :final ignoredCount,
        ) =>
          {
            'status': 'processed',
            'messageCount': messageCount,
            'capturedCount': capturedCount,
            'duplicateCount': duplicateCount,
            'ignoredCount': ignoredCount,
          },
      };
    } catch (error, stackTrace) {
      smsDebugLog('syncInbox failed', error, stackTrace);
      return {
        'status': 'error',
        'error': error.toString(),
      };
    }
  }

  static Future<void> _refreshHomeWidgets(AppDatabase database) async {
    try {
      smsDebugLog('refreshing home widgets after background capture');
      await refreshHomeWidgets(database);
      smsDebugLog('home widgets refreshed');
    } catch (error, stackTrace) {
      smsDebugLog('home widget refresh failed', error, stackTrace);
    }
  }

  static Map<String, Object?> _resultMap(SmsCaptureResult result) {
    return {'result': result.name};
  }
}
