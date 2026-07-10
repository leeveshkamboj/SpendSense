import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';

void main() {
  testWidgets('shows original SMS on transaction detail', (tester) async {
    const rawSms =
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.';
    final database = AppDatabase(NativeDatabase.memory());
    final creditCards = CreditCardRepository(database);
    final cardId = await creditCards.create(
      const NewCreditCard(
        bank: 'HDFC',
        lastFourDigits: '5534',
        nickname: 'HDFC ••5534',
        colorValue: 0xFF00695C,
        iconName: 'credit_card',
      ),
    );

    final transactionId = await CardTransactionRepository(database).insert(
      NewCardTransaction(
        creditCardId: cardId,
        kind: 'expense',
        amountPaise: 41167,
        merchant: 'ZOMATO LTD',
        transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
        source: 'SMS',
        rawSms: rawSms,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          cardTransactionReceiptsProvider.overrideWith(
            (ref, id) async => [],
          ),
        ],
        child: MaterialApp(
          home: TransactionDetailScreen(transactionId: transactionId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Original SMS'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Original SMS'), findsOneWidget);
    expect(find.text(rawSms), findsOneWidget);

    await database.close();
  });

  testWidgets('saves merchant display name from transaction detail', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final creditCards = CreditCardRepository(database);
    final cardId = await creditCards.create(
      const NewCreditCard(
        bank: 'HDFC',
        lastFourDigits: '5534',
        nickname: 'HDFC ••5534',
        colorValue: 0xFF00695C,
        iconName: 'credit_card',
      ),
    );

    final transactionId = await CardTransactionRepository(database).insert(
      NewCardTransaction(
        creditCardId: cardId,
        kind: 'expense',
        amountPaise: 41167,
        merchant: 'ZOMATO LTD',
        transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
        source: 'SMS',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          cardTransactionReceiptsProvider.overrideWith(
            (ref, id) async => [],
          ),
        ],
        child: MaterialApp(
          home: TransactionDetailScreen(transactionId: transactionId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Zomato Dinner');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionDetailScreen)),
    );
    final displayNames =
        await container.read(merchantDisplayNamesProvider.future);

    expect(displayNames['ZOMATO LTD'], 'Zomato Dinner');

    await database.close();
  });
}
