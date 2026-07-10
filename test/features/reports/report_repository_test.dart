import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/analytics/data/analytics_repository.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/categories/data/category_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/reports/data/report_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('ReportRepository', () {
    late AppDatabase database;
    late ReportRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      final creditCards = CreditCardRepository(database);
      final cardTransactions = CardTransactionRepository(database);
      final recoverables = RecoverableRepository(
        database: database,
        transactions: cardTransactions,
      );
      final budgets = BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: cardTransactions,
      );
      repository = ReportRepository(
        cardTransactions: cardTransactions,
        creditCards: creditCards,
        bankAccounts: BankAccountRepository(database),
        categories: CategoryRepository(database),
        budgets: budgets,
        bills: BillsRepository(
          creditCards: creditCards,
          transactions: cardTransactions,
          recoverables: recoverables,
        ),
        analytics: AnalyticsRepository(
          budgets: budgets,
          creditCards: creditCards,
          cardTransactions: cardTransactions,
          tags: TagRepository(database),
        ),
        recoverables: recoverables,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('builds empty snapshot from fresh database', () async {
      final snapshot = await repository.buildSnapshot(asOf: DateTime(2026, 7, 10));

      expect(snapshot.cardTransactions, isEmpty);
      expect(snapshot.recoverablesByPerson, isEmpty);
    });

    test('builds snapshot with card transactions and recoverables by person', () async {
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
      final recoverables = RecoverableRepository(
        database: database,
        transactions: transactions,
      );
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      final txId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      await recoverables.markRecoverable(
        transactionId: txId,
        isRecoverable: true,
        person: 'Alex Kumar',
      );

      final snapshot = await repository.buildSnapshot(asOf: DateTime(2026, 7, 10));

      expect(snapshot.cardTransactions, hasLength(1));
      expect(snapshot.cardTransactions.single.merchant, 'ZOMATO LTD');
      expect(snapshot.cardTransactions.single.cardNickname, 'HDFC ••5534');
      expect(snapshot.recoverablesByPerson['Alex Kumar'], 50000);
    });
  });
}
