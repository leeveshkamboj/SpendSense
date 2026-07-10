import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/presentation/sms_import_screen.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';
import 'package:spendsense/features/sms_capture/sms_sync_service.dart';

final smsSyncServiceProvider = Provider<SmsSyncService>((ref) {
  return SmsSyncService(
    inbox: ref.watch(smsInboxGatewayProvider),
    captureService: ref.watch(smsCaptureServiceProvider),
    settings: ref.watch(onboardingRepositoryProvider),
    permissionGateway: ref.watch(smsPermissionGatewayProvider),
  );
});
