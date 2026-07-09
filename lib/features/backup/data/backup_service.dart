import 'package:spendsense/features/backup/domain/backup_metadata.dart';

sealed class BackupActionResult {
  const BackupActionResult();

  const factory BackupActionResult.success(
    String message, {
    BackupMetadata? metadata,
  }) = BackupActionSuccess;
  const factory BackupActionResult.failure(Object error) = BackupActionFailure;
  const factory BackupActionResult.cancelled() = BackupActionCancelled;
}

final class BackupActionSuccess extends BackupActionResult {
  const BackupActionSuccess(this.message, {this.metadata});

  final String message;
  final BackupMetadata? metadata;
}

final class BackupActionFailure extends BackupActionResult {
  const BackupActionFailure(this.error);

  final Object error;
}

final class BackupActionCancelled extends BackupActionResult {
  const BackupActionCancelled();
}

abstract class BackupService {
  Future<BackupActionResult> exportBackup({required String password});

  Future<BackupActionResult> restoreBackup({
    required String backupFilePath,
    required String password,
  });

  Future<String?> pickBackupFile();

  Future<BackupActionResult> exportSalvageBackup({
    required String sourceBackupPath,
  });
}

String formatBackupFileName(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return 'SpendSense_Backup_$year-$month-$day.ssb';
}
