import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/dashboard/data/dashboard_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('DashboardRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late RecoverableRepository recoverables;
    late DashboardRepository dashboard;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      recoverables = RecoverableRepository(
        database: database,
        transactions: transactions,
      );
      dashboard = DashboardRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
        budgets: BudgetRepository(
          database: database,
          creditCards: creditCards,
          cardTransactions: transactions,
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('returns aggregate and per-card spend for current budget period', () async {
      final hdfcId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: hdfcId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final sbiId = await creditCards.create(
        const NewCreditCard(
          bank: 'SBI',
          lastFourDigits: '1234',
          nickname: 'SBI ••1234',
          colorValue: 0xFF1565C0,
          iconName: 'credit_card',
        ),
      );
      await creditCards.configureBilling(
        cardId: sbiId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final hdfcCycle = (await creditCards.listCycles(hdfcId))
          .firstWhere((row) => row.startDate == DateTime(2026, 6, 16));
      final sbiCycle = (await creditCards.listCycles(sbiId))
          .firstWhere((row) => row.startDate == DateTime(2026, 6, 16));

      await transactions.insert(
        NewCardTransaction(
          creditCardId: hdfcId,
          billingCycleId: hdfcCycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      final sbiTransactionId = await transactions.insert(
        NewCardTransaction(
          creditCardId: sbiId,
          billingCycleId: sbiCycle.id,
          kind: 'expense',
          amountPaise: 30000,
          merchant: 'SWIGGY',
          transactionAt: DateTime(2026, 7, 8),
          source: 'SMS',
        ),
      );
      await recoverables.markRecoverable(
        transactionId: sbiTransactionId,
        isRecoverable: true,
        person: 'Alex',
      );

      final summary = await dashboard.cardSpendSummary(asOf: DateTime(2026, 7, 10));

      expect(summary.totalPaise, 80000);
      expect(summary.cards, hasLength(2));
      expect(
        summary.cards.map((row) => row.nickname).toList(),
        containsAll(['HDFC ••5534', 'SBI ••1234']),
      );
      expect(
        summary.cards.firstWhere((row) => row.nickname == 'HDFC ••5534').spentPaise,
        50000,
      );
      expect(
        summary.cards.firstWhere((row) => row.nickname == 'SBI ••1234').spentPaise,
        30000,
      );
    });

    test('returns recent card transactions newest first', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          kind: 'expense',
          amountPaise: 10000,
          merchant: 'OLDER',
          transactionAt: DateTime(2026, 7, 8),
          source: 'SMS',
        ),
      );
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          kind: 'expense',
          amountPaise: 20000,
          merchant: 'NEWER',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );

      final recent = await dashboard.recentTransactions(limit: 5);

      expect(recent, hasLength(2));
      expect(recent.first.merchant, 'NEWER');
      expect(recent.first.amountPaise, 20000);
      expect(recent.last.merchant, 'OLDER');
    });
  });
}
