import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/presentation/transactions_screen.dart';

void main() {
  group('Transactions screen', () {
    testWidgets('shows card transactions grouped by billing cycle', (
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
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );

      final capture = SmsCaptureService(
        creditCards: creditCards,
        cardTransactions: CardTransactionRepository(database),
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
      );
      await capture.processSms(
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(home: TransactionsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('ZOMATO LTD'), findsOneWidget);
      expect(find.textContaining('16/06/2026'), findsOneWidget);

      await database.close();
    });

    testWidgets('shows bank transactions grouped by month on Accounts segment', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());
      final capture = SmsCaptureService(
        creditCards: CreditCardRepository(database),
        cardTransactions: CardTransactionRepository(database),
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
      );
      await capture.processSms(
        'Dear UPI user A/C X0428 debited by 25000.00 on 09-07-26 to MERCHANT Ref 987654',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(home: TransactionsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      expect(find.text('MERCHANT'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);

      await database.close();
    });
  });
}
