import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AppPinStore {
  Future<void> writePinHash(String hash);
  Future<String?> readPinHash();
  Future<void> clearPinHash();
}

class SecureAppPinStore implements AppPinStore {
  SecureAppPinStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _pinHashKey = 'app_lock_pin_hash';
  final FlutterSecureStorage _storage;

  @override
  Future<void> writePinHash(String hash) {
    return _storage.write(key: _pinHashKey, value: hash);
  }

  @override
  Future<String?> readPinHash() {
    return _storage.read(key: _pinHashKey);
  }

  @override
  Future<void> clearPinHash() {
    return _storage.delete(key: _pinHashKey);
  }
}

class InMemoryAppPinStore implements AppPinStore {
  String? pinHash;

  @override
  Future<void> clearPinHash() async {
    pinHash = null;
  }

  @override
  Future<String?> readPinHash() async => pinHash;

  @override
  Future<void> writePinHash(String hash) async {
    pinHash = hash;
  }
}
