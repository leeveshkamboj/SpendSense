import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/analytics/data/analytics_repository.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('AnalyticsRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late TagRepository tags;
    late BudgetRepository budgets;
    late AnalyticsRepository analytics;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      tags = TagRepository(database);
      budgets = BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      );
      analytics = AnalyticsRepository(
        budgets: budgets,
        creditCards: creditCards,
        cardTransactions: transactions,
        tags: tags,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('compares current and previous budget month totals', () async {
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

      final currentCycle = (await creditCards.listCycles(cardId))
          .firstWhere((row) => row.startDate == DateTime(2026, 6, 16));
      final previousCycle = (await creditCards.listCycles(cardId))
          .firstWhere((row) => row.startDate == DateTime(2026, 5, 16));

      final currentTxId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: currentCycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          category: 'Food',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: previousCycle.id,
          kind: 'expense',
          amountPaise: 20000,
          merchant: 'SWIGGY',
          category: 'Food',
          transactionAt: DateTime(2026, 6, 10),
          source: 'SMS',
        ),
      );
      await tags.setForCardTransaction(
        transactionId: currentTxId,
        tagNames: ['Dining'],
      );

      final snapshot = await analytics.snapshot(asOf: DateTime(2026, 7, 10));

      expect(snapshot.currentCategoryTotals['Food'], 50000);
      expect(snapshot.previousCategoryTotals['Food'], 20000);
      expect(snapshot.currentTagTotals['Dining'], 50000);
    });

    test('compares current and previous billing cycles for a card', () async {
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

      final currentCycle = (await creditCards.listCycles(cardId))
          .firstWhere((row) => row.startDate == DateTime(2026, 6, 16));
      final previousCycle = (await creditCards.listCycles(cardId))
          .firstWhere((row) => row.startDate == DateTime(2026, 5, 16));

      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: currentCycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: previousCycle.id,
          kind: 'expense',
          amountPaise: 20000,
          merchant: 'SWIGGY',
          transactionAt: DateTime(2026, 6, 10),
          source: 'SMS',
        ),
      );

      final comparison = await analytics.billingCycleComparison(
        creditCardId: cardId,
        asOf: DateTime(2026, 7, 10),
      );

      expect(comparison, isNotNull);
      expect(comparison!.currentSpendPaise, 50000);
      expect(comparison.previousSpendPaise, 20000);
    });
  });
}
