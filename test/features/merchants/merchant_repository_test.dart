import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';

void main() {
  group('MerchantRepository', () {
    late AppDatabase database;
    late MerchantRepository merchants;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      merchants = MerchantRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('auto-adds new merchant from transaction raw name', () async {
      await merchants.ensureFromTransaction(rawName: 'ZOMATO LTD');

      final rows = await merchants.listAll();
      expect(rows, hasLength(1));
      expect(rows.single.rawName, 'ZOMATO LTD');
    });

    test('does not duplicate merchant on repeat capture', () async {
      await merchants.ensureFromTransaction(rawName: 'ZOMATO LTD');
      await merchants.ensureFromTransaction(rawName: 'ZOMATO LTD');

      expect((await merchants.listAll()).length, 1);
    });

    test('resolves dictionary category for new merchant', () async {
      final category = await merchants.resolveDefaultCategory('ZOMATO LTD');

      expect(category, 'Food');
      expect((await merchants.listAll()).single.rawName, 'ZOMATO LTD');
    });

    test('user category override beats dictionary permanently', () async {
      await merchants.ensureFromTransaction(rawName: 'ZOMATO LTD');
      await merchants.updateDefaults(
        rawName: 'ZOMATO LTD',
        defaultCategory: 'Shopping',
      );

      expect(await merchants.resolveDefaultCategory('ZOMATO LTD'), 'Shopping');
    });
  });
}
