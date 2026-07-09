import 'package:spendsense/core/database/database.dart';

class DatabaseHealthChecker {
  Future<bool> isHealthy(AppDatabase database) async {
    try {
      await database.customSelect('SELECT 1').getSingle();
      await database.select(database.appSettings).get();
      return true;
    } catch (_) {
      return false;
    }
  }
}
