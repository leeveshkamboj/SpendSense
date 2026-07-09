import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/data/receipt_repository.dart';

void main() {
  group('ReceiptRepository', () {
    late AppDatabase database;
    late CardTransactionRepository transactions;
    late ReceiptRepository receipts;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      transactions = CardTransactionRepository(database);
      receipts = ReceiptRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('stores multiple receipt paths per transaction', () async {
      final transactionId = await database.into(database.cardTransactions).insert(
            CardTransactionsCompanion.insert(
              creditCardId: 1,
              kind: 'expense',
              amountPaise: 10000,
              merchant: 'SHOP',
              transactionAt: DateTime(2026, 7, 9),
              source: 'Manual',
              createdAt: DateTime.now(),
            ),
          );

      await receipts.add(
        transactionId: transactionId,
        filePath: '/data/receipt1.jpg',
      );
      await receipts.add(
        transactionId: transactionId,
        filePath: '/data/receipt2.jpg',
      );

      expect(
        await receipts.listForTransaction(transactionId),
        ['/data/receipt1.jpg', '/data/receipt2.jpg'],
      );
    });
  });
}
