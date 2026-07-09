import 'package:permission_handler/permission_handler.dart';

enum SmsPermissionState {
  granted,
  denied,
}

abstract class SmsPermissionGateway {
  Future<SmsPermissionState> check();
  Future<SmsPermissionState> request();
}

class PermissionHandlerSmsGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionState> check() async {
    final status = await Permission.sms.status;
    return status.isGranted
        ? SmsPermissionState.granted
        : SmsPermissionState.denied;
  }

  @override
  Future<SmsPermissionState> request() async {
    final status = await Permission.sms.request();
    return status.isGranted
        ? SmsPermissionState.granted
        : SmsPermissionState.denied;
  }
}

class InMemorySmsPermissionGateway implements SmsPermissionGateway {
  InMemorySmsPermissionGateway(this._state);

  SmsPermissionState _state;

  @override
  Future<SmsPermissionState> check() async => _state;

  @override
  Future<SmsPermissionState> request() async {
    _state = SmsPermissionState.granted;
    return _state;
  }

  void deny() {
    _state = SmsPermissionState.denied;
  }
}
