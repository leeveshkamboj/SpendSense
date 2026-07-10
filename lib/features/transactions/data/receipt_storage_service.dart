import 'dart:io';

import 'package:path/path.dart' as p;

class ReceiptStorageService {
  ReceiptStorageService({required this.receiptsDirectory});

  final String receiptsDirectory;

  Future<String> importReceipt({
    required int transactionId,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Selected file no longer exists');
    }

    final destinationDirectory = Directory(
      p.join(receiptsDirectory, transactionId.toString()),
    );
    await destinationDirectory.create(recursive: true);

    final safeName = p.basename(sourcePath).replaceAll(RegExp(r'[^\w.\-]'), '_');
    final destinationPath = p.join(
      destinationDirectory.path,
      '${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  Future<void> deleteReceiptFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
