import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/settings/data/app_preferences_repository.dart';

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>((ref) {
  return AppPreferencesRepository(ref.watch(databaseProvider));
});

final themeModeProvider = FutureProvider<String>((ref) {
  return ref.watch(appPreferencesRepositoryProvider).themeMode();
});

final appLockEnabledProvider = FutureProvider<bool>((ref) {
  return ref.watch(appPreferencesRepositoryProvider).appLockEnabled();
});
