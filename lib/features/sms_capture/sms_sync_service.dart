import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/sms_capture/sms_debug_log.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';

typedef SmsSyncProcessor = Future<SmsCaptureResult> Function(String sms);

class SmsSyncService {
  factory SmsSyncService({
    required SmsInboxGateway inbox,
    required SmsCaptureService captureService,
    required OnboardingRepository settings,
    required SmsPermissionGateway permissionGateway,
  }) {
    // Inbox rescans (incl. 36h RCS lookback) must not spam "could not parse"
    // for every unparsed historical message on each open/sync.
    return SmsSyncService.testing(
      inbox: inbox,
      processor: (sms) =>
          captureService.processSms(sms, notifyUnparsed: false),
      settings: settings,
      permissionGateway: permissionGateway,
    );
  }

  SmsSyncService.testing({
    required SmsInboxGateway inbox,
    required SmsSyncProcessor processor,
    required OnboardingRepository settings,
    required SmsPermissionGateway permissionGateway,
  })  : _inbox = inbox,
        _processSms = processor,
        _settings = settings,
        _permissionGateway = permissionGateway;

  final SmsInboxGateway _inbox;
  final SmsSyncProcessor _processSms;
  final OnboardingRepository _settings;
  final SmsPermissionGateway _permissionGateway;

  Future<SmsSyncResult> syncNewMessages({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    smsDebugLog('syncNewMessages start now=$clock');

    if (!await _settings.isOnboardingComplete()) {
      smsDebugLog('sync skipped: onboardingIncomplete');
      return const SmsSyncResult.skipped(SmsSyncSkipReason.onboardingIncomplete);
    }

    final permission = await _permissionGateway.check();
    if (permission != SmsPermissionState.granted) {
      smsDebugLog('sync skipped: permissionDenied ($permission)');
      return const SmsSyncResult.skipped(SmsSyncSkipReason.permissionDenied);
    }

    final lastSync = await _settings.lastSmsSyncAt();
    if (lastSync == null) {
      final importCompleted = await _settings.importCompleted();
      if (importCompleted) {
        await _settings.saveLastSmsSyncAt(clock);
        smsDebugLog('sync skipped: baselineEstablished at $clock');
        return const SmsSyncResult.skipped(SmsSyncSkipReason.baselineEstablished);
      }

      smsDebugLog('sync skipped: importIncomplete');
      return const SmsSyncResult.skipped(SmsSyncSkipReason.importIncomplete);
    }

    // MMS/RCS bodies often land after the PDU row (and after a later SMS
    // advances the cursor). Re-scan a lookback window and rely on duplicate
    // detection so late RCS text is still captured.
    final since = lastSync.subtract(const Duration(hours: 36));
    smsDebugLog('sync reading inbox lastSync=$lastSync since=$since');
    final messages = await _inbox.readInbox(since: since);
    final newMessages = messages
        .where((message) => message.receivedAt.isAfter(since))
        .toList()
      ..sort((a, b) => a.receivedAt.compareTo(b.receivedAt));
    smsDebugLog(
      'sync inbox rows=${messages.length} candidates=${newMessages.length}',
    );

    if (newMessages.isEmpty) {
      return const SmsSyncResult.processed(
        messageCount: 0,
        capturedCount: 0,
        duplicateCount: 0,
        ignoredCount: 0,
      );
    }

    var captured = 0;
    var duplicates = 0;
    var ignored = 0;
    var processedCount = 0;
    var latestReceivedAt = lastSync;

    for (final message in newMessages) {
      processedCount++;
      final preview = message.body.length > 80
          ? '${message.body.substring(0, 80)}…'
          : message.body;
      smsDebugLog(
        'sync process channel=${message.channel.name} '
        'sender=${message.sender} at=${message.receivedAt} body="$preview"',
      );
      final result = await _processSms(message.body);
      smsDebugLog('sync process result=${result.name}');
      switch (result) {
        case SmsCaptureResult.captured:
          captured++;
        case SmsCaptureResult.duplicate:
          duplicates++;
        case SmsCaptureResult.ignored:
          ignored++;
      }

      if (message.receivedAt.isAfter(latestReceivedAt)) {
        latestReceivedAt = message.receivedAt;
      }
    }

    if (latestReceivedAt.isAfter(lastSync)) {
      await _settings.saveLastSmsSyncAt(latestReceivedAt);
      smsDebugLog('sync advanced lastSmsSyncAt -> $latestReceivedAt');
    }

    smsDebugLog(
      'sync done processed=$processedCount captured=$captured '
      'dup=$duplicates ignored=$ignored',
    );

    return SmsSyncResult.processed(
      messageCount: processedCount,
      capturedCount: captured,
      duplicateCount: duplicates,
      ignoredCount: ignored,
    );
  }
}

enum SmsSyncSkipReason {
  onboardingIncomplete,
  permissionDenied,
  importIncomplete,
  baselineEstablished,
}

sealed class SmsSyncResult {
  const SmsSyncResult();

  const factory SmsSyncResult.skipped(SmsSyncSkipReason reason) =
      SkippedSmsSyncResult;

  const factory SmsSyncResult.processed({
    required int messageCount,
    required int capturedCount,
    required int duplicateCount,
    required int ignoredCount,
  }) = ProcessedSmsSyncResult;
}

final class SkippedSmsSyncResult extends SmsSyncResult {
  const SkippedSmsSyncResult(this.reason);

  final SmsSyncSkipReason reason;
}

final class ProcessedSmsSyncResult extends SmsSyncResult {
  const ProcessedSmsSyncResult({
    required this.messageCount,
    required this.capturedCount,
    required this.duplicateCount,
    required this.ignoredCount,
  });

  final int messageCount;
  final int capturedCount;
  final int duplicateCount;
  final int ignoredCount;
}
