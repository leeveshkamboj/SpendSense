import 'dart:io';

import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/backup/domain/backup_metadata.dart';
import 'package:spendsense/features/backup/engine/backup_file_codec.dart';
import 'package:spendsense/features/backup/engine/backup_receipt_archive.dart';

class BackupRepository {
  BackupRepository({
    required AppDatabase database,
    required String databaseFilePath,
    this.receiptsDirectoryPath,
  })  : _database = database,
        _databaseFilePath = databaseFilePath;

  final AppDatabase _database;
  final String _databaseFilePath;
  final String? receiptsDirectoryPath;

  Future<DateTime> exportEncrypted({
    required String password,
    required String destinationPath,
  }) async {
    final exportedAt = DateTime.now();
    final snapshotPath = '$destinationPath.snapshot.db';

    await _database.customStatement("VACUUM INTO '$snapshotPath'");
    final databaseBytes = await File(snapshotPath).readAsBytes();
    await File(snapshotPath).delete();

    final receiptFiles = receiptsDirectoryPath == null
        ? const <String, String>{}
        : await BackupReceiptArchive.readFromDirectory(receiptsDirectoryPath!);

    final fileBytes = await BackupFileCodec.encode(
      exportedAt: exportedAt,
      schemaVersion: _database.schemaVersion,
      databaseBytes: databaseBytes,
      password: password,
      receiptFiles: receiptFiles,
    );
    await File(destinationPath).writeAsBytes(fileBytes);

    return exportedAt;
  }

  Future<BackupMetadata> restoreEncrypted({
    required String backupFilePath,
    required String password,
  }) async {
    final fileName = backupFilePath.split(Platform.pathSeparator).last;
    final fileBytes = await File(backupFilePath).readAsBytes();
    final decoded = await BackupFileCodec.decode(
      fileBytes: fileBytes,
      password: password,
      fileName: fileName,
    );

    await _database.close();
    await File(_databaseFilePath).writeAsBytes(decoded.databaseBytes);

    if (receiptsDirectoryPath != null) {
      final receiptsDirectory = Directory(receiptsDirectoryPath!);
      if (await receiptsDirectory.exists()) {
        await for (final entity in receiptsDirectory.list()) {
          await entity.delete(recursive: true);
        }
      }
      await BackupReceiptArchive.writeToDirectory(
        receiptsDirectory: receiptsDirectoryPath!,
        files: decoded.receiptFiles,
      );
    }

    return decoded.metadata;
  }
}
