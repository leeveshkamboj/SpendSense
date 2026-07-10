import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('BillsRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late RecoverableRepository recoverables;
    late BillsRepository bills;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      recoverables = RecoverableRepository(
        database: database,
        transactions: transactions,
      );
      bills = BillsRepository(
        creditCards: creditCards,
        transactions: transactions,
        recoverables: recoverables,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('lists unpaid billed cycles from active cards only', () async {
      final activeCardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: activeCardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final archivedCardId = await creditCards.create(
        const NewCreditCard(
          bank: 'SBI',
          lastFourDigits: '1234',
          nickname: 'SBI ••1234',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: archivedCardId,
        billDayOfMonth: 10,
        dueDateOffsetDays: 20,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );
      await (database.update(database.creditCards)
            ..where((card) => card.id.equals(archivedCardId)))
          .write(const CreditCardsCompanion(isArchived: Value(true)));

      final billedCycle = (await creditCards.listCycles(activeCardId))
          .firstWhere((cycle) => cycle.billGenerated);
      await transactions.insert(
        NewCardTransaction(
          creditCardId: activeCardId,
          billingCycleId: billedCycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'SMS',
        ),
      );

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));

      expect(rows.length, 1);
      expect(rows.single.cardNickname, 'HDFC ••5534');
      expect(rows.single.totalOutstandingPaise, 50000);
      expect(rows.single.netOutstandingPaise, 50000);
      expect(rows.single.status, isNot(BillingCycleStatus.paid));
    });

    test('excludes fully paid billed cycles', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final billedCycle = (await creditCards.listCycles(cardId))
          .firstWhere((cycle) => cycle.billGenerated);
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'expense',
          amountPaise: 5000,
          merchant: 'TEST',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'Manual',
        ),
      );
      await (database.update(database.billingCycles)
            ..where((cycle) => cycle.id.equals(billedCycle.id)))
          .write(
        const BillingCyclesCompanion(paymentsAppliedPaise: Value(5000)),
      );

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));

      expect(rows, isEmpty);
    });

    test('recordManualPayment applies partial payment', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final billedCycle = (await creditCards.listCycles(cardId))
          .firstWhere((cycle) => cycle.billGenerated);
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'TEST',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'Manual',
        ),
      );

      await bills.recordManualPayment(
        cycleId: billedCycle.id,
        paymentPaise: 20000,
      );

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      final updated = rows.firstWhere((row) => row.cycleId == billedCycle.id);

      expect(updated.paymentsAppliedPaise, 20000);
      expect(updated.totalOutstandingPaise, 30000);
      expect(updated.status, isNot(BillingCycleStatus.paid));
    });

    test('markBillPaidInFull removes bill from unpaid list', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final billedCycle = (await creditCards.listCycles(cardId))
          .firstWhere((cycle) => cycle.billGenerated);
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'TEST',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'Manual',
        ),
      );

      await bills.markBillPaidInFull(cycleId: billedCycle.id);

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));

      expect(rows, isEmpty);
    });

    test('subtracts refunds and ignores card payments in bill amount', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final billedCycle = (await creditCards.listCycles(cardId))
          .firstWhere((cycle) => cycle.billGenerated);
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'expense',
          amountPaise: 100000,
          merchant: 'STORE',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'SMS',
        ),
      );
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'refund',
          amountPaise: 25000,
          merchant: 'STORE',
          transactionAt: billedCycle.startDate.add(const Duration(days: 2)),
          source: 'SMS',
        ),
      );
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'card_payment',
          amountPaise: 10000,
          merchant: 'PAYMENT',
          transactionAt: billedCycle.startDate.add(const Duration(days: 3)),
          source: 'SMS',
        ),
      );

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));

      expect(rows.single.totalOutstandingPaise, 75000);
    });

    test('excludes billed cycles older than billing history window', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2025, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));

      expect(rows.every((bill) => bill.dueDate!.year >= 2026), isTrue);
    });
  });
}
