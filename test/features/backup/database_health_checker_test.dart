import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/backup/data/database_health_checker.dart';

void main() {
  group('DatabaseHealthChecker', () {
    test('reports healthy database', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final healthy = await DatabaseHealthChecker().isHealthy(database);

      expect(healthy, isTrue);
    });
  });
}
