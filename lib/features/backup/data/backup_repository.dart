import 'dart:io';

import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/backup/domain/backup_metadata.dart';
import 'package:spendsense/features/backup/engine/backup_file_codec.dart';

class BackupRepository {
  BackupRepository({
    required AppDatabase database,
    required String databaseFilePath,
  })  : _database = database,
        _databaseFilePath = databaseFilePath;

  final AppDatabase _database;
  final String _databaseFilePath;

  Future<DateTime> exportEncrypted({
    required String password,
    required String destinationPath,
  }) async {
    final exportedAt = DateTime.now();
    final snapshotPath = '$destinationPath.snapshot.db';

    await _database.customStatement("VACUUM INTO '$snapshotPath'");
    final databaseBytes = await File(snapshotPath).readAsBytes();
    await File(snapshotPath).delete();

    final fileBytes = await BackupFileCodec.encode(
      exportedAt: exportedAt,
      schemaVersion: _database.schemaVersion,
      databaseBytes: databaseBytes,
      password: password,
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

    return decoded.metadata;
  }
}
