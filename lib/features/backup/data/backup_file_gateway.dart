abstract class BackupFileGateway {
  Future<String?> pickBackupFile();

  Future<String?> pickExportDestination(String suggestedName);
}
