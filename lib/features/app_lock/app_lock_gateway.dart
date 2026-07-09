import 'package:local_auth/local_auth.dart';

abstract class AppLockGateway {
  Future<bool> authenticateWithDeviceCredential();
  Future<bool> canCheckBiometrics();
}

class InMemoryAppLockGateway implements AppLockGateway {
  InMemoryAppLockGateway({
    this.deviceCredentialSuccess = true,
    this.biometricsAvailable = true,
  });

  bool deviceCredentialSuccess;
  bool biometricsAvailable;
  var authenticateCalls = 0;

  @override
  Future<bool> authenticateWithDeviceCredential() async {
    authenticateCalls++;
    return deviceCredentialSuccess;
  }

  @override
  Future<bool> canCheckBiometrics() async => biometricsAvailable;
}

class PlatformAppLockGateway implements AppLockGateway {
  PlatformAppLockGateway([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> authenticateWithDeviceCredential() {
    return _auth.authenticate(
      localizedReason: 'Verify your identity to reset app lock',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }

  @override
  Future<bool> canCheckBiometrics() async {
    final biometrics = await _auth.getAvailableBiometrics();
    return biometrics.isNotEmpty;
  }
}
