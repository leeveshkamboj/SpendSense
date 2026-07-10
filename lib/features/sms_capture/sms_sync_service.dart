import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/onboarding/sms_import_log.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';

typedef SmsSyncProcessor = Future<SmsCaptureResult> Function(String sms);

class SmsSyncService {
  SmsSyncService({
    required SmsInboxGateway inbox,
    required SmsCaptureService captureService,
    required OnboardingRepository settings,
    required SmsPermissionGateway permissionGateway,
  })  : _inbox = inbox,
        _processSms = captureService.processSms,
        _settings = settings,
        _permissionGateway = permissionGateway;

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

    if (!await _settings.isOnboardingComplete()) {
      smsImportLog('Skipping SMS sync because onboarding is not complete');
      return const SmsSyncResult.skipped(SmsSyncSkipReason.onboardingIncomplete);
    }

    final permission = await _permissionGateway.check();
    if (permission != SmsPermissionState.granted) {
      smsImportLog('Skipping SMS sync because permission is $permission');
      return const SmsSyncResult.skipped(SmsSyncSkipReason.permissionDenied);
    }

    final lastSync = await _settings.lastSmsSyncAt();
    if (lastSync == null) {
      final importCompleted = await _settings.importCompleted();
      if (importCompleted) {
        smsImportLog(
          'Establishing SMS sync baseline for existing install at '
          '${clock.toIso8601String()}',
        );
        await _settings.saveLastSmsSyncAt(clock);
        return const SmsSyncResult.skipped(SmsSyncSkipReason.baselineEstablished);
      }

      smsImportLog('Skipping SMS sync because historical import is not complete');
      return const SmsSyncResult.skipped(SmsSyncSkipReason.importIncomplete);
    }

    final since = lastSync.subtract(const Duration(seconds: 1));
    smsImportLog('Syncing inbox messages since ${since.toIso8601String()}');

    final messages = await _inbox.readInbox(since: since);
    final newMessages = messages
        .where((message) => message.receivedAt.isAfter(lastSync))
        .toList()
      ..sort((a, b) => a.receivedAt.compareTo(b.receivedAt));

    if (newMessages.isEmpty) {
      smsImportLog('No new inbox messages to process');
      return const SmsSyncResult.processed(
        messageCount: 0,
        capturedCount: 0,
        duplicateCount: 0,
        ignoredCount: 0,
      );
    }

    smsImportLog('Processing ${newMessages.length} new inbox messages');

    var captured = 0;
    var duplicates = 0;
    var ignored = 0;
    var latestReceivedAt = lastSync;

    for (final message in newMessages) {
      final result = await _processSms(message.body);
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

    await _settings.saveLastSmsSyncAt(latestReceivedAt);

    smsImportLog(
      'SMS sync finished: messages=${newMessages.length} '
      'captured=$captured duplicates=$duplicates ignored=$ignored '
      'lastSync=${latestReceivedAt.toIso8601String()}',
    );

    return SmsSyncResult.processed(
      messageCount: newMessages.length,
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
