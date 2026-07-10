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

    test('updates credit limit on an existing card', () async {
      final id = await repository.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      await repository.updateCreditLimit(
        cardId: id,
        creditLimitPaise: 20000000,
      );

      final card = await repository.getById(id);
      expect(card?.creditLimitPaise, 20000000);
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

    test('reconfiguring billing deduplicates cycles and backfills transactions',
        () async {
      final id = await repository.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      final historyFrom = DateTime(2025, 12, 20);
      final historyTo = DateTime(2026, 2, 20);

      await repository.configureBilling(
        cardId: id,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: historyFrom,
        historyTo: historyTo,
      );

      final firstCount = (await repository.listCycles(id)).length;

      await repository.configureBilling(
        cardId: id,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: historyFrom,
        historyTo: historyTo,
      );

      final cycles = await repository.listCycles(id);
      expect(cycles.length, firstCount);

      final cycleId = await repository.findBillingCycleIdForTransaction(
        cardId: id,
        transactionAt: DateTime(2026, 1, 10),
      );
      expect(cycleId, isNotNull);
    });

    test('changing bill day reassigns transactions to new cycles', () async {
      final id = await repository.create(
        const NewCreditCard(
          bank: 'SBI',
          lastFourDigits: '8401',
          nickname: 'SBI ••8401',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      final historyFrom = DateTime(2026, 4, 1);
      final historyTo = DateTime(2026, 6, 30);

      await repository.updateBillingSettings(
        cardId: id,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: historyFrom,
        historyTo: historyTo,
      );

      final transactionId = await database.into(database.cardTransactions).insert(
            CardTransactionsCompanion.insert(
              creditCardId: id,
              kind: 'expense',
              amountPaise: 10000,
              merchant: 'TEST',
              transactionAt: DateTime(2026, 5, 10),
              source: 'manual',
              createdAt: DateTime(2026, 5, 10),
            ),
          );

      await repository.updateBillingSettings(
        cardId: id,
        billDayOfMonth: 1,
        dueDateOffsetDays: 20,
        historyFrom: historyFrom,
        historyTo: historyTo,
      );

      final transaction = await (database.select(database.cardTransactions)
            ..where((row) => row.id.equals(transactionId)))
          .getSingle();
      final cycle = await repository.findCycleById(transaction.billingCycleId!);

      expect(cycle, isNotNull);
      expect(cycle!.endDate, DateTime(2026, 6, 1));
      expect(cycle.dueDate, DateTime(2026, 6, 21));

      final card = await repository.getById(id);
      expect(card?.billDayOfMonth, 1);
      expect(card?.dueDateOffsetDays, 20);
    });
  });
}
