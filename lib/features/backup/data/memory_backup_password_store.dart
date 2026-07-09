import 'package:spendsense/features/backup/data/backup_password_store.dart';

class MemoryBackupPasswordStore implements BackupPasswordStore {
  String? _password;

  @override
  Future<void> clearPassword() async {
    _password = null;
  }

  @override
  Future<String?> readPassword() async => _password;

  @override
  Future<void> savePassword(String password) async {
    _password = password;
  }
}
