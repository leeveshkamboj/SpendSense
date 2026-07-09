import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spendsense/features/backup/data/backup_password_store.dart';

class SecureBackupPasswordStore implements BackupPasswordStore {
  SecureBackupPasswordStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _passwordKey = 'backup_password';

  final FlutterSecureStorage _storage;

  @override
  Future<void> clearPassword() {
    return _storage.delete(key: _passwordKey);
  }

  @override
  Future<String?> readPassword() {
    return _storage.read(key: _passwordKey);
  }

  @override
  Future<void> savePassword(String password) {
    return _storage.write(key: _passwordKey, value: password);
  }
}
