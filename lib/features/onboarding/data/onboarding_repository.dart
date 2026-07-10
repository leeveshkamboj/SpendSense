import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class OnboardingRepository {
  OnboardingRepository(this._database);

  final AppDatabase _database;

  Future<AppSetting> _settings() async {
    final rows = await _database.select(_database.appSettings).get();
    if (rows.isEmpty) {
      await _database
          .into(_database.appSettings)
          .insert(const AppSettingsCompanion());
      return _database.select(_database.appSettings).getSingle();
    }
    return rows.single;
  }

  Future<bool> isOnboardingComplete() async {
    return (await _settings()).onboardingComplete;
  }

  Future<void> markOnboardingComplete() async {
    await _database.update(_database.appSettings).write(
      const AppSettingsCompanion(onboardingComplete: Value(true)),
    );
  }

  Future<int> importLastIndex() async => (await _settings()).importLastIndex;

  Future<bool> importCompleted() async => (await _settings()).importCompleted;

  Future<DateTime?> lastSmsSyncAt() async {
    final millis = (await _settings()).lastSmsSyncAtMs;
    if (millis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> saveLastSmsSyncAt(DateTime syncedAt) async {
    await _database.update(_database.appSettings).write(
      AppSettingsCompanion(
        lastSmsSyncAtMs: Value(syncedAt.millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> saveImportProgress({
    required int lastIndex,
    required bool completed,
  }) async {
    await _database.update(_database.appSettings).write(
      AppSettingsCompanion(
        importLastIndex: Value(lastIndex),
        importCompleted: Value(completed),
      ),
    );
  }

  Future<void> resetSmsImport() async {
    await saveImportProgress(lastIndex: 0, completed: false);
    await saveLastSmsSyncAt(DateTime.fromMillisecondsSinceEpoch(0));
  }
}
