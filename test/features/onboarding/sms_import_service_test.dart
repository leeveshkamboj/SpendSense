import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/onboarding/sms_import_service.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';

void main() {
  group('SmsImportService', () {
    test('reports completion when resuming past the end of the message list', () async {
      final service = SmsImportService.testing(
        (_) async => SmsCaptureResult.ignored,
      );
      var lastProcessed = -1;
      var lastTotal = -1;

      await service.importMessages(
        const ['one', 'two'],
        startIndex: 2,
        onProgress: (processed, total) {
          lastProcessed = processed;
          lastTotal = total;
        },
      );

      expect(lastProcessed, 2);
      expect(lastTotal, 2);
    });

    test('reports initial progress before processing messages', () async {
      final service = SmsImportService.testing(
        (_) async => SmsCaptureResult.ignored,
      );
      final progress = <int>[];

      await service.importMessages(
        const ['one'],
        onProgress: (processed, total) => progress.add(processed),
      );

      expect(progress, [0, 1]);
    });
  });
}
