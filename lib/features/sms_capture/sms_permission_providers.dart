import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';

final smsPermissionGatewayProvider = Provider<SmsPermissionGateway>((ref) {
  return PermissionHandlerSmsGateway();
});

final smsPermissionStateProvider = FutureProvider<SmsPermissionState>((ref) {
  return ref.watch(smsPermissionGatewayProvider).check();
});
