import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class BackupReceiptArchive {
  const BackupReceiptArchive._();

  static Future<Map<String, String>> readFromDirectory(
    String receiptsDirectory,
  ) async {
    final directory = Directory(receiptsDirectory);
    if (!await directory.exists()) {
      return const {};
    }

    final files = <String, String>{};
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final relative = p.relative(entity.path, from: receiptsDirectory);
      if (relative.startsWith('..')) {
        continue;
      }

      files[relative] = base64Encode(await entity.readAsBytes());
    }

    return files;
  }

  static Future<void> writeToDirectory({
    required String receiptsDirectory,
    required Map<String, String> files,
  }) async {
    if (files.isEmpty) {
      return;
    }

    final root = Directory(receiptsDirectory);
    await root.create(recursive: true);

    for (final entry in files.entries) {
      final target = File(p.join(receiptsDirectory, entry.key));
      await target.parent.create(recursive: true);
      await target.writeAsBytes(base64Decode(entry.value));
    }
  }
}
