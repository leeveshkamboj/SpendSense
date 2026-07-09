import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/settings/data/app_data_repository.dart';

void main() {
  group('AppDataRepository', () {
    late AppDatabase database;
    late AppDataRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = AppDataRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('deleteAllData removes all credit cards and transactions', () async {
      final creditCards = CreditCardRepository(database);
      await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      await repository.deleteAllData();

      expect(await creditCards.listActive(), isEmpty);
    });
  });
}
