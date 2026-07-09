import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_edit_repository.dart';

void main() {
  group('TransactionEditRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late TransactionEditRepository edit;
    late BillsRepository bills;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      edit = TransactionEditRepository(
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

    test('update changes amount and bill outstanding recalculates', () async {
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
          category: 'Food',
          transactionAt: billedCycle.startDate.add(const Duration(days: 1)),
          source: 'SMS',
        ),
      );

      final beforeUpdate =
          await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      expect(beforeUpdate.single.totalOutstandingPaise, 50000);

      await edit.update(
        transactionId: transactionId,
        amountPaise: 30000,
        merchant: 'ZOMATO LTD',
        category: 'Food',
        transactionAt: billedCycle.startDate.add(const Duration(days: 2)),
      );

      final updated = (await transactions.getById(transactionId))!;
      expect(updated.amountPaise, 30000);

      final afterUpdate =
          await bills.listUnpaidBills(asOf: DateTime(2026, 7, 20));
      expect(afterUpdate.single.totalOutstandingPaise, 30000);
    });
  });
}
