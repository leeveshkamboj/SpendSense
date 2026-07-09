abstract class BackupPasswordStore {
  Future<String?> readPassword();

  Future<void> savePassword(String password);

  Future<void> clearPassword();
}
