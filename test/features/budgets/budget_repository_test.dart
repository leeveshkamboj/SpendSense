import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('BudgetRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late BudgetRepository budgets;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      budgets = BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('tracks monthly spend for current budget period', () async {
      await budgets.setMonthlyLimit(100000);

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

      final cycle = (await creditCards.listCycles(cardId))
          .firstWhere((row) => row.startDate == DateTime(2026, 6, 16));

      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: cycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );

      final progress = await budgets.monthlyProgress(asOf: DateTime(2026, 7, 10));

      expect(progress, isNotNull);
      expect(progress!.spentPaise, 50000);
      expect(progress.remainingPaise, 50000);
      expect(progress.projectedPaise, greaterThan(50000));
    });

    test('stores category budgets', () async {
      await budgets.setCategoryBudget(category: 'Food', limitPaise: 30000);
      await budgets.setCategoryBudget(category: 'Fuel', limitPaise: 10000);

      final rows = await budgets.listCategoryBudgets();

      expect(rows.map((row) => row.category).toList(), ['Food', 'Fuel']);
    });
  });
}
