import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_repository.dart';
import 'package:spendsense/features/dashboard/data/dashboard_repository.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('HomeWidgetRepository', () {
    late AppDatabase database;
    late HomeWidgetRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
      final budgets = BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      );
      repository = HomeWidgetRepository(
        dashboard: DashboardRepository(
          creditCards: creditCards,
          cardTransactions: transactions,
        ),
        budgets: budgets,
        creditCards: creditCards,
        creditLimitPools: CreditLimitPoolRepository(database),
        bills: BillsRepository(
          creditCards: creditCards,
          transactions: transactions,
          recoverables: RecoverableRepository(
            database: database,
            transactions: transactions,
          ),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('quick summary uses budget personal spend excluding recoverables', () async {
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
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
      await BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      ).setMonthlyLimit(100000);

      final snapshot = await repository.quickSummary(asOf: DateTime(2026, 7, 10));

      expect(snapshot.spentPaise, 50000);
      expect(snapshot.budgetLimitPaise, 100000);
      expect(snapshot.budgetRemainingPaise, 50000);
      expect(snapshot.cardSpendSegments, hasLength(1));
      expect(snapshot.cardSpendSegments.single.colorValue, 0xFF00695C);
    });

    test(
      'credit utilization includes spend and total credit limit when limits are set',
      () async {
        final creditCards = CreditCardRepository(database);
        final transactions = CardTransactionRepository(database);
        final cardId = await creditCards.create(
          const NewCreditCard(
            bank: 'HDFC',
            lastFourDigits: '5534',
            nickname: 'HDFC ••5534',
            colorValue: 0xFF00695C,
            iconName: 'credit_card',
            creditLimitPaise: 200000,
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

        final snapshot = await repository.creditUtilization(
          asOf: DateTime(2026, 7, 10),
        );

        expect(snapshot.spentPaise, 50000);
        expect(snapshot.creditLimitPaise, 200000);
        expect(snapshot.needsLimitPrompt, isFalse);
        expect(snapshot.cardSegments, hasLength(1));
        expect(snapshot.cardSegments.single.colorValue, 0xFF00695C);
      },
    );

    test('credit utilization prompts to set limit when any card lacks one', () async {
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
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
          amountPaise: 25000,
          merchant: 'SWIGGY',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );

      final snapshot = await repository.creditUtilization(
        asOf: DateTime(2026, 7, 10),
      );

      expect(snapshot.spentPaise, 25000);
      expect(snapshot.creditLimitPaise, isNull);
      expect(snapshot.needsLimitPrompt, isTrue);
    });

    test('recent transactions returns latest captures newest first', () async {
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
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

      final snapshot = await repository.recentTransactions(limit: 5);

      expect(snapshot.transactions, hasLength(2));
      expect(snapshot.transactions.first.merchant, 'NEWER');
      expect(snapshot.transactions.first.amountPaise, 20000);
      expect(snapshot.transactions.last.merchant, 'OLDER');
      expect(snapshot.transactions.first.colorValue, 0xFF00695C);
    });

    test('upcoming bills lists unpaid dues sorted by due date', () async {
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
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
          merchant: 'ZOMATO LTD',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'SMS',
        ),
      );

      final snapshot = await repository.upcomingBills(asOf: DateTime(2026, 7, 20));

      expect(snapshot.bills, hasLength(1));
      expect(snapshot.bills.single.cardNickname, 'HDFC ••5534');
      expect(snapshot.bills.single.netOutstandingPaise, 50000);
      expect(snapshot.bills.single.dueDate, isNotNull);
      expect(snapshot.bills.single.colorValue, 0xFF00695C);
    });

    test('budget progress includes cycle spend remaining and daily budget', () async {
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
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
      await BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      ).setMonthlyLimit(100000);

      final snapshot = await repository.budgetProgress(asOf: DateTime(2026, 7, 10));

      expect(snapshot.spentPaise, 50000);
      expect(snapshot.limitPaise, 100000);
      expect(snapshot.remainingPaise, 50000);
      expect(snapshot.dailyBudgetPaise, greaterThan(0));
      expect(snapshot.needsBudgetPrompt, isFalse);
      expect(snapshot.cardSpendSegments, hasLength(1));
      expect(snapshot.cardSpendSegments.single.colorValue, 0xFF00695C);
    });

    test('budget progress prompts to set budget when monthly limit unset', () async {
      final snapshot = await repository.budgetProgress(asOf: DateTime(2026, 7, 10));

      expect(snapshot.needsBudgetPrompt, isTrue);
      expect(snapshot.limitPaise, isNull);
      expect(snapshot.remainingPaise, isNull);
      expect(snapshot.dailyBudgetPaise, isNull);
    });
  });
}
