import 'package:spendsense/features/onboarding/sms_import_log.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_log.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/sms_capture/sms_parse_diagnostics.dart';

typedef SmsImportProcessor = Future<SmsCaptureResult> Function(String sms);

class SmsImportService {
  SmsImportService(SmsCaptureService captureService)
      : _processSms = captureService.processSms;

  SmsImportService.testing(SmsImportProcessor processor) : _processSms = processor;

  final SmsImportProcessor _processSms;

  Future<ImportProgress> importMessages(
    List<String> messages, {
    int startIndex = 0,
    void Function(int processed, int total)? onProgress,
  }) async {
    final total = messages.length;
    smsImportLog(
      'Starting import: total=$total startIndex=$startIndex',
    );

    if (startIndex >= total) {
      smsImportLog('Import already complete for current message batch');
      onProgress?.call(total, total);
      return ImportProgress(
        processedCount: total,
        capturedCount: 0,
        duplicateCount: 0,
        ignoredCount: 0,
      );
    }

    onProgress?.call(startIndex, total);

    var captured = 0;
    var duplicates = 0;
    var ignored = 0;
    var ignoredBankLike = 0;

    for (var index = startIndex; index < messages.length; index++) {
      final message = messages[index];
      final result = await _processSms(message);
      switch (result) {
        case SmsCaptureResult.captured:
          captured++;
        case SmsCaptureResult.duplicate:
          duplicates++;
          if (looksBankRelatedSms(message)) {
            smsImportLog(
              'Duplicate during import: "${smsPreview(message)}"',
            );
          }
        case SmsCaptureResult.ignored:
          ignored++;
          if (looksBankRelatedSms(message)) {
            ignoredBankLike++;
            final diagnostic = diagnoseSmsParse(message);
            smsImportLog(
              'Ignored bank-like SMS during import: $diagnostic '
              'preview="${smsPreview(message)}"',
            );
          }
      }

      final processed = index + 1;
      if (processed == total || processed % 25 == 0) {
        smsImportLog(
          'Import progress: $processed/$total '
          '(captured=$captured duplicates=$duplicates ignored=$ignored)',
        );
      }

      onProgress?.call(processed, total);
    }

    final progress = ImportProgress(
      processedCount: total,
      capturedCount: captured,
      duplicateCount: duplicates,
      ignoredCount: ignored,
    );

    smsImportLog(
      'Import finished: processed=${progress.processedCount} '
      'captured=${progress.capturedCount} '
      'duplicates=${progress.duplicateCount} '
      'ignored=${progress.ignoredCount} '
      'ignoredBankLike=$ignoredBankLike',
    );

    if (progress.capturedCount == 0 && total > 0) {
      smsImportLog(
        'No transactions were captured. Sample message: '
        '${_preview(messages.first)}',
      );
    }

    return progress;
  }
}

String _preview(String message) {
  final trimmed = message.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (trimmed.length <= 120) {
    return trimmed;
  }
  return '${trimmed.substring(0, 120)}...';
}

class ImportProgress {
  const ImportProgress({
    required this.processedCount,
    required this.capturedCount,
    required this.duplicateCount,
    required this.ignoredCount,
  });

  final int processedCount;
  final int capturedCount;
  final int duplicateCount;
  final int ignoredCount;
}
