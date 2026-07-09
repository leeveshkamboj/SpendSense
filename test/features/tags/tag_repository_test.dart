import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('TagRepository', () {
    late AppDatabase database;
    late TagRepository tags;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      tags = TagRepository(database);
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('assigns multiple tags to a card transaction', () async {
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
          amountPaise: 5000,
          merchant: 'CAFE',
          transactionAt: DateTime(2026, 7, 9),
          source: 'Manual',
        ),
      );

      await tags.setForCardTransaction(
        transactionId: txId,
        tagNames: ['Personal', 'Office'],
      );

      expect(
        await tags.listForCardTransaction(txId),
        ['Office', 'Personal'],
      );
    });

    test('replaces tags when updated', () async {
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
          amountPaise: 5000,
          merchant: 'CAFE',
          transactionAt: DateTime(2026, 7, 9),
          source: 'Manual',
        ),
      );

      await tags.setForCardTransaction(
        transactionId: txId,
        tagNames: ['Personal'],
      );
      await tags.setForCardTransaction(
        transactionId: txId,
        tagNames: ['Office'],
      );

      expect(await tags.listForCardTransaction(txId), ['Office']);
    });
  });
}
