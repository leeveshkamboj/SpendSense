import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:spendsense/features/app_lock/app_lock_gateway.dart';
import 'package:spendsense/features/app_lock/app_pin_store.dart';
import 'package:spendsense/features/settings/data/app_preferences_repository.dart';

class AppLockRepository {
  AppLockRepository({
    required AppPreferencesRepository preferences,
    required AppLockGateway gateway,
    AppPinStore? pinStore,
  })  : _preferences = preferences,
        _gateway = gateway,
        _pinStore = pinStore ?? SecureAppPinStore();

  final AppPreferencesRepository _preferences;
  final AppLockGateway _gateway;
  final AppPinStore _pinStore;
  final Sha256 _sha256 = Sha256();

  Future<bool> isEnabled() => _preferences.appLockEnabled();

  Future<bool> isBiometricEnabled() => _preferences.appLockBiometricEnabled();

  Future<void> enableWithPin(String pin) async {
    await _pinStore.writePinHash(await _hashPin(pin));
    await _preferences.setAppLockEnabled(true);
  }

  Future<void> disable() async {
    await _pinStore.clearPinHash();
    await _preferences.setAppLockEnabled(false);
    await _preferences.setAppLockBiometricEnabled(false);
  }

  Future<void> setBiometricEnabled(bool enabled) {
    return _preferences.setAppLockBiometricEnabled(enabled);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _pinStore.readPinHash();
    if (stored == null) {
      return false;
    }
    return stored == await _hashPin(pin);
  }

  Future<bool> canUnlockWithBiometrics() async {
    if (!await isBiometricEnabled()) {
      return false;
    }
    return _gateway.canCheckBiometrics();
  }

  Future<bool> unlockWithBiometrics() async {
    if (!await canUnlockWithBiometrics()) {
      return false;
    }
    return _gateway.authenticateWithBiometrics();
  }

  Future<bool> resetPinWithDeviceCredential(String newPin) async {
    final verified = await _gateway.authenticateWithDeviceCredential();
    if (!verified) {
      return false;
    }

    await _pinStore.writePinHash(await _hashPin(newPin));
    await _preferences.setAppLockEnabled(true);
    return true;
  }

  Future<String> _hashPin(String pin) async {
    final secret = await _sha256.hash(utf8.encode(pin));
    return secret.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
