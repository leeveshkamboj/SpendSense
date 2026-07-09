import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('RecoverableRepository', () {
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

    test('marks expense recoverable with person', () async {
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
          amountPaise: 10000,
          merchant: 'DINNER',
          transactionAt: DateTime(2026, 7, 9),
          source: 'Manual',
        ),
      );

      await recoverables.markRecoverable(
        transactionId: txId,
        isRecoverable: true,
        person: 'Rahul',
      );

      final tx = await transactions.getById(txId);
      expect(tx!.isRecoverable, isTrue);
      expect(tx.recoverablePerson, 'Rahul');
      expect(await recoverables.listPersonNames(), ['Rahul']);
    });

    test('split creates personal and recoverable lines', () async {
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
          amountPaise: 10000,
          merchant: 'DINNER',
          transactionAt: DateTime(2026, 7, 9),
          source: 'Manual',
        ),
      );

      await recoverables.splitTransaction(
        transactionId: txId,
        personalAmountPaise: 6000,
        recoverableAmountPaise: 4000,
        person: 'Priya',
      );

      final all = await transactions.listAll();
      expect(all.length, 2);
      expect(all.where((tx) => tx.isRecoverable).single.amountPaise, 4000);
      expect(all.where((tx) => !tx.isRecoverable).single.amountPaise, 6000);
    });

    test('reduces bills net outstanding by unsettled recoverables only', () async {
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
          .firstWhere((row) => row.billGenerated);

      final personalId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: cycle.id,
          kind: 'expense',
          amountPaise: 30000,
          merchant: 'PERSONAL',
          transactionAt: DateTime(2026, 7, 9),
          source: 'Manual',
        ),
      );
      final recoverableId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: cycle.id,
          kind: 'expense',
          amountPaise: 20000,
          merchant: 'FRIEND',
          transactionAt: DateTime(2026, 7, 10),
          source: 'Manual',
        ),
      );
      await recoverables.markRecoverable(
        transactionId: recoverableId,
        isRecoverable: true,
        person: 'Rahul',
      );

      final creditId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: cycle.id,
          kind: 'refund',
          amountPaise: 5000,
          merchant: 'REPAYMENT',
          transactionAt: DateTime(2026, 7, 11),
          source: 'Manual',
        ),
      );
      await recoverables.linkRecovery(
        creditTransactionId: creditId,
        recoverableTransactionId: recoverableId,
        amountPaise: 5000,
      );

      final rows = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      expect(rows.single.totalOutstandingPaise, 45000);
      expect(rows.single.netOutstandingPaise, 30000);
      expect(personalId, isNotNull);
    });
  });
}
