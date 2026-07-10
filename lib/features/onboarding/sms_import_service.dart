import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';

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

    if (startIndex >= total) {
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

    for (var index = startIndex; index < messages.length; index++) {
      final result = await _processSms(messages[index]);
      switch (result) {
        case SmsCaptureResult.captured:
          captured++;
        case SmsCaptureResult.duplicate:
          duplicates++;
        case SmsCaptureResult.ignored:
          ignored++;
      }

      onProgress?.call(index + 1, total);
    }

    return ImportProgress(
      processedCount: total,
      capturedCount: captured,
      duplicateCount: duplicates,
      ignoredCount: ignored,
    );
  }
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
