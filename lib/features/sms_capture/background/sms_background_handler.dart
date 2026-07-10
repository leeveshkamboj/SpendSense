import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/sms_capture/background/sms_capture_runtime.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_log.dart';

const _backgroundChannelName = 'com.spendsense.spendsense/sms_background';
const _readyChannelName = 'com.spendsense.spendsense/sms_background_ready';

@pragma('vm:entry-point')
void smsBackgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  SmsBackgroundHandler.install();
}

class SmsBackgroundHandler {
  static void install() {
    const backgroundChannel = MethodChannel(_backgroundChannelName);
    const readyChannel = MethodChannel(_readyChannelName);

    backgroundChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'processSms':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          return processIncomingSms(
            body: args['body'] as String,
            receivedAtMs: args['receivedAtMs'] as int,
          );
        default:
          throw PlatformException(
            code: 'not_implemented',
            message: 'Unknown method ${call.method}',
          );
      }
    });

    readyChannel.invokeMethod<void>('ready');
  }

  static Future<Map<String, Object?>> processIncomingSms({
    required String body,
    required int receivedAtMs,
  }) async {
    final probeDatabase = AppDatabase();
    try {
      final settings = OnboardingRepository(probeDatabase);
      if (!await settings.isOnboardingComplete()) {
        smsCaptureLog('Background SMS ignored because onboarding is incomplete');
        return _resultMap(SmsCaptureResult.ignored);
      }

      if (!await settings.importCompleted()) {
        smsCaptureLog('Background SMS ignored because import is incomplete');
        return _resultMap(SmsCaptureResult.ignored);
      }
    } finally {
      await probeDatabase.close();
    }

    final runtime = await SmsCaptureRuntime.open();
    final settings = OnboardingRepository(runtime.database);

    final result = await runtime.service.processSms(body);
    if (result == SmsCaptureResult.captured ||
        result == SmsCaptureResult.duplicate) {
      final receivedAt = DateTime.fromMillisecondsSinceEpoch(receivedAtMs);
      final lastSync = await settings.lastSmsSyncAt();
      if (lastSync == null || receivedAt.isAfter(lastSync)) {
        await settings.saveLastSmsSyncAt(receivedAt);
      }
    }

    return _resultMap(result);
  }

  static Map<String, Object?> _resultMap(SmsCaptureResult result) {
    return {'result': result.name};
  }
}
