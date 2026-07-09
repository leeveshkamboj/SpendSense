import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_copy_repository.dart';

void main() {
  group('TransactionCopyRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late TagRepository tags;
    late TransactionCopyRepository copy;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      tags = TagRepository(database);
      copy = TransactionCopyRepository(
        transactions: transactions,
        tags: tags,
        creditCards: creditCards,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('draftFrom pre-fills merchant category card and tags', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      final transactionId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          kind: 'expense',
          amountPaise: 41167,
          merchant: 'ZOMATO LTD',
          category: 'Food',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      await tags.setForCardTransaction(
        transactionId: transactionId,
        tagNames: ['Personal'],
      );

      final draft = await copy.draftFrom(transactionId);

      expect(draft.creditCardId, cardId);
      expect(draft.merchant, 'ZOMATO LTD');
      expect(draft.category, 'Food');
      expect(draft.tags, ['Personal']);
    });

    test('saveCopy creates manual transaction with edited amount and date', () async {
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

      final sourceId = await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          kind: 'expense',
          amountPaise: 41167,
          merchant: 'ZOMATO LTD',
          category: 'Food',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      await tags.setForCardTransaction(
        transactionId: sourceId,
        tagNames: ['Personal'],
      );

      final draft = await copy.draftFrom(sourceId);
      final copiedId = await copy.saveCopy(
        draft: draft,
        amountPaise: 99999,
        transactionAt: DateTime(2026, 7, 10, 12),
      );

      final copied = (await transactions.getById(copiedId))!;
      expect(copied.source, 'Manual');
      expect(copied.amountPaise, 99999);
      expect(copied.merchant, 'ZOMATO LTD');
      expect(copied.category, 'Food');
      expect(copied.transactionAt, DateTime(2026, 7, 10, 12));
      expect(await tags.listForCardTransaction(copiedId), ['Personal']);
    });
  });
}
