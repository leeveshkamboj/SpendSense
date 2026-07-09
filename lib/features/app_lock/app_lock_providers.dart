import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/app_lock/app_lock_gateway.dart';
import 'package:spendsense/features/app_lock/app_lock_repository.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

final appLockGatewayProvider = Provider<AppLockGateway>((ref) {
  return PlatformAppLockGateway();
});

final appLockRepositoryProvider = Provider<AppLockRepository>((ref) {
  return AppLockRepository(
    preferences: ref.watch(appPreferencesRepositoryProvider),
    gateway: ref.watch(appLockGatewayProvider),
  );
});
