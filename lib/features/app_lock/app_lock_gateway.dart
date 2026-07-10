import 'package:local_auth/local_auth.dart';

abstract class AppLockGateway {
  Future<bool> authenticateWithDeviceCredential();
  Future<bool> authenticateWithBiometrics();
  Future<bool> canCheckBiometrics();
}

class InMemoryAppLockGateway implements AppLockGateway {
  InMemoryAppLockGateway({
    this.deviceCredentialSuccess = true,
    this.biometricAuthenticateSuccess = true,
    this.biometricsAvailable = true,
  });

  bool deviceCredentialSuccess;
  bool biometricAuthenticateSuccess;
  bool biometricsAvailable;
  var authenticateCalls = 0;
  var biometricAuthenticateCalls = 0;

  @override
  Future<bool> authenticateWithDeviceCredential() async {
    authenticateCalls++;
    return deviceCredentialSuccess;
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    biometricAuthenticateCalls++;
    return biometricAuthenticateSuccess;
  }

  @override
  Future<bool> canCheckBiometrics() async => biometricsAvailable;
}

class PlatformAppLockGateway implements AppLockGateway {
  PlatformAppLockGateway([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> authenticateWithDeviceCredential() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Verify your identity to reset app lock',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock SpendSense',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return false;
      }
      if (!await _auth.canCheckBiometrics) {
        return false;
      }
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
