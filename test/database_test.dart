import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';

void main() {
  group('App database', () {
    test('initializes with schema version 4 and domain tables', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) {
            return AppDatabase(NativeDatabase.memory());
          }),
        ],
      );
      addTearDown(container.dispose);

      final database = container.read(databaseProvider);
      expect(database.schemaVersion, 4);

      final tables = await database.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      ).get();

      expect(
        tables.map((row) => row.read<String>('name')).toList(),
        [
          'app_settings',
          'bank_account_transactions',
          'bank_accounts',
          'billing_cycles',
          'card_transactions',
          'credit_cards',
        ],
      );

      await database.close();
    });
  });
}
