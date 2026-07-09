import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('CardTransactionRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late BillsRepository bills;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
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

    test('deleting expense removes unpaid bill for cycle', () async {
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
      final transactionId = await transactions.insert(
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

      final beforeDelete =
          await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      expect(beforeDelete.single.totalOutstandingPaise, 50000);

      await transactions.delete(transactionId);

      expect(await transactions.getById(transactionId), isNull);
      final afterDelete =
          await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      expect(afterDelete, isEmpty);
    });
  });
}
