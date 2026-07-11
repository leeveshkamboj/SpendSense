import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/linking/data/linking_repository.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/presentation/copy_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/edit_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/transactions_screen.dart';
import 'package:spendsense/features/sms_capture/data/seen_sms_repository.dart';

void main() {
  group('Transactions screen', () {
    testWidgets('shows card transactions in a flat list', (
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
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        seenSms: SeenSmsRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: creditCards,
          cardTransactions: CardTransactionRepository(database),
        ),
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

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Zomato Ltd'), findsOneWidget);

      await database.close();
    });

    testWidgets('shows empty state when card billing is not configured', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());
      final creditCards = CreditCardRepository(database);
      await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
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

      expect(
        find.text('Configure billing on your cards in Accounts'),
        findsOneWidget,
      );

      await database.close();
    });

    testWidgets('swipe delete shows undo snackbar and restores transaction', (
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
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        seenSms: SeenSmsRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: creditCards,
          cardTransactions: CardTransactionRepository(database),
        ),
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

      await tester.drag(find.text('Zomato Ltd'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Zomato Ltd'), findsNothing);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Zomato Ltd'), findsOneWidget);

      await database.close();
    });

    testWidgets('long-press copy opens pre-filled copy form', (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      final creditCards = CreditCardRepository(database);
      final cardTransactions = CardTransactionRepository(database);
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
        cardTransactions: cardTransactions,
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        seenSms: SeenSmsRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: creditCards,
          cardTransactions: cardTransactions,
        ),
      );
      await capture.processSms(
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
      );

      final router = GoRouter(
        initialLocation: '/transactions',
        routes: [
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: 'copy/:id',
                builder: (context, state) => CopyTransactionScreen(
                  sourceTransactionId:
                      int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Zomato Ltd'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(find.text('Copy transaction'), findsOneWidget);
      expect(find.text('Category: Food'), findsOneWidget);

      await database.close();
    });

    testWidgets('swipe right opens edit form with existing amount', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());
      final creditCards = CreditCardRepository(database);
      final cardTransactions = CardTransactionRepository(database);
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
        cardTransactions: cardTransactions,
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        seenSms: SeenSmsRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: creditCards,
          cardTransactions: cardTransactions,
        ),
      );
      await capture.processSms(
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
      );

      final router = GoRouter(
        initialLocation: '/transactions',
        routes: [
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => const SizedBox.shrink(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => EditTransactionScreen(
                      transactionId:
                          int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('Zomato Ltd'), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Edit transaction'), findsOneWidget);
      expect(find.text('411.67'), findsOneWidget);

      await database.close();
    });
  });
}
