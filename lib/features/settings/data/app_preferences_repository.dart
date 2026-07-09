import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._database);

  final AppDatabase _database;

  Future<AppSetting> _row() async {
    final rows = await _database.select(_database.appSettings).get();
    if (rows.isEmpty) {
      final id = await _database.into(_database.appSettings).insert(
            const AppSettingsCompanion(),
          );
      return (await (_database.select(_database.appSettings)
            ..where((row) => row.id.equals(id)))
          .getSingle());
    }
    return rows.first;
  }

  Future<bool> locationPermissionExplained() async {
    return (await _row()).locationPermissionExplained;
  }

  Future<void> markLocationPermissionExplained() async {
    final row = await _row();
    await (_database.update(_database.appSettings)
          ..where((settings) => settings.id.equals(row.id)))
        .write(
      const AppSettingsCompanion(locationPermissionExplained: Value(true)),
    );
  }

  Future<String> themeMode() async {
    return (await _row()).themeMode;
  }

  Future<void> setThemeMode(String mode) async {
    final row = await _row();
    await (_database.update(_database.appSettings)
          ..where((settings) => settings.id.equals(row.id)))
        .write(AppSettingsCompanion(themeMode: Value(mode)));
  }

  Future<bool> appLockEnabled() async {
    return (await _row()).appLockEnabled;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final row = await _row();
    await (_database.update(_database.appSettings)
          ..where((settings) => settings.id.equals(row.id)))
        .write(AppSettingsCompanion(appLockEnabled: Value(enabled)));
  }

  Future<bool> appLockBiometricEnabled() async {
    return (await _row()).appLockBiometricEnabled;
  }

  Future<void> setAppLockBiometricEnabled(bool enabled) async {
    final row = await _row();
    await (_database.update(_database.appSettings)
          ..where((settings) => settings.id.equals(row.id)))
        .write(AppSettingsCompanion(appLockBiometricEnabled: Value(enabled)));
  }
}
