import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_cycle_move_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_merge_repository.dart';

void main() {
  group('Transaction merge and cycle move', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late TransactionMergeRepository merge;
    late TransactionCycleMoveRepository cycleMove;
    late BillsRepository bills;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      merge = TransactionMergeRepository(
        database: database,
        transactions: transactions,
        tags: TagRepository(database),
      );
      cycleMove = TransactionCycleMoveRepository(
        transactions: transactions,
        creditCards: creditCards,
      );
      bills = BillsRepository(
        creditCards: creditCards,
        transactions: transactions,
        recoverables: RecoverableRepository(
          database: database,
          transactions: transactions,
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    Future<int> createCardWithBilling() async {
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
      return cardId;
    }

    test('merge combines amounts and deletes duplicate', () async {
      final cardId = await createCardWithBilling();
      final billedCycle = (await creditCards.listCycles(cardId))
          .firstWhere((cycle) => cycle.billGenerated);

      final survivorId = await transactions.insert(
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
      final duplicateId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billedCycle.id,
          kind: 'expense',
          amountPaise: 25000,
          merchant: 'ZOMATO LTD',
          transactionAt: billedCycle.startDate.add(const Duration(days: 2)),
          source: 'Manual',
        ),
      );

      await merge.merge(
        survivorTransactionId: survivorId,
        duplicateTransactionId: duplicateId,
      );

      expect(await transactions.getById(duplicateId), isNull);
      expect((await transactions.getById(survivorId))!.amountPaise, 75000);

      final unpaid = await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      expect(unpaid.single.totalOutstandingPaise, 75000);
    });

    test('cycle move reassigns billing cycle', () async {
      final cardId = await createCardWithBilling();
      final cycles = await creditCards.listCycles(cardId);
      final sourceCycle = cycles.firstWhere((cycle) => cycle.billGenerated);
      final targetCycle = cycles.lastWhere((cycle) => cycle.billGenerated);

      final transactionId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: sourceCycle.id,
          kind: 'expense',
          amountPaise: 10000,
          merchant: 'SHOP',
          transactionAt: sourceCycle.startDate.add(const Duration(days: 1)),
          source: 'Manual',
        ),
      );

      await cycleMove.moveToCycle(
        transactionId: transactionId,
        targetCycleId: targetCycle.id,
      );

      expect(
        (await transactions.getById(transactionId))!.billingCycleId,
        targetCycle.id,
      );
    });
  });
}
