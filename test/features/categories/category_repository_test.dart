import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/categories/data/category_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('CategoryRepository', () {
    late AppDatabase database;
    late CategoryRepository categories;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      categories = CategoryRepository(database);
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('seeds default categories on first access', () async {
      await categories.ensureDefaults();

      expect(
        await categories.listNames(),
        containsAll(['Food', 'Fuel', 'Shopping', 'Miscellaneous']),
      );
    });

    test('allows renaming a category', () async {
      await categories.ensureDefaults();
      await categories.rename(from: 'Food', to: 'Dining');

      final names = await categories.listNames();
      expect(names, contains('Dining'));
      expect(names, isNot(contains('Food')));
    });

    test('deleting category reassigns transactions to Miscellaneous', () async {
      await categories.ensureDefaults();
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
          amountPaise: 5000,
          merchant: 'CAFE',
          category: 'Food',
          transactionAt: DateTime(2026, 7, 9),
          source: 'Manual',
        ),
      );

      await categories.delete('Food');

      final tx = (await transactions.listAll()).single;
      expect(tx.category, 'Miscellaneous');
      expect(await categories.listNames(), isNot(contains('Food')));
    });
  });
}
