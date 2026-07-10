import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/transactions/data/receipt_storage_service.dart';

void main() {
  group('ReceiptStorageService', () {
    late Directory tempDirectory;
    late ReceiptStorageService storage;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('receipts_test');
      storage = ReceiptStorageService(receiptsDirectory: tempDirectory.path);
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('copies picked file into transaction folder', () async {
      final source = File('${tempDirectory.path}/source.jpg');
      await source.writeAsString('receipt');

      final storedPath = await storage.importReceipt(
        transactionId: 42,
        sourcePath: source.path,
      );

      expect(await File(storedPath).exists(), isTrue);
      expect(storedPath, contains('${tempDirectory.path}${Platform.pathSeparator}42'));
      expect(await File(storedPath).readAsString(), 'receipt');
    });

    test('deletes stored receipt file', () async {
      final source = File('${tempDirectory.path}/source.pdf');
      await source.writeAsString('pdf');

      final storedPath = await storage.importReceipt(
        transactionId: 7,
        sourcePath: source.path,
      );

      await storage.deleteReceiptFile(storedPath);

      expect(await File(storedPath).exists(), isFalse);
    });
  });
}
