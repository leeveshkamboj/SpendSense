import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';

void main() {
  group('CreditCardRepository', () {
    late AppDatabase database;
    late CreditCardRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = CreditCardRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('creates credit card with domain fields', () async {
      final id = await repository.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      final card = await repository.getById(id);

      expect(card?.bank, 'HDFC');
      expect(card?.lastFourDigits, '5534');
      expect(card?.nickname, 'HDFC ••5534');
      expect(card?.billDayOfMonth, isNull);
    });

    test('creates billing cycles retroactively when bill date is configured', () async {
      final id = await repository.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      await repository.configureBilling(
        cardId: id,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2025, 12, 20),
        historyTo: DateTime(2026, 2, 20),
      );

      final configured = await repository.getById(id);
      expect(configured?.billDayOfMonth, 15);
      expect(configured?.dueDateOffsetDays, 18);

      final cycles = await repository.listCycles(id);
      expect(cycles.length, 3);
      expect(cycles.first.endDate, DateTime(2026, 3, 15));
      expect(cycles.last.endDate, DateTime(2026, 1, 15));
    });
  });
}
