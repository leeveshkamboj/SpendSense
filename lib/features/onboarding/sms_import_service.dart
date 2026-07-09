import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';

class SmsImportService {
  SmsImportService(this._captureService);

  final SmsCaptureService _captureService;

  Future<ImportProgress> importMessages(
    List<String> messages, {
    int startIndex = 0,
    void Function(int processed, int total)? onProgress,
  }) async {
    var captured = 0;
    var duplicates = 0;

    for (var index = startIndex; index < messages.length; index++) {
      final result = await _captureService.processSms(messages[index]);
      if (result == SmsCaptureResult.captured) captured++;
      if (result == SmsCaptureResult.duplicate) duplicates++;
      onProgress?.call(index + 1, messages.length);
    }

    return ImportProgress(
      processedCount: messages.length,
      capturedCount: captured,
      duplicateCount: duplicates,
    );
  }
}

class ImportProgress {
  const ImportProgress({
    required this.processedCount,
    required this.capturedCount,
    required this.duplicateCount,
  });

  final int processedCount;
  final int capturedCount;
  final int duplicateCount;
}
