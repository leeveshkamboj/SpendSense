import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_detail_screen.dart';

void main() {
  group('Accounts screen', () {
    testWidgets('shows separate Credit Cards and Bank Accounts sections', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Credit Cards'), findsOneWidget);
      expect(find.text('Bank Accounts'), findsOneWidget);
      expect(find.text('No credit cards yet'), findsOneWidget);

      await database.close();
    });

    testWidgets('lists configured card with billing cycles on detail screen', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());
      final repository = CreditCardRepository(database);
      final cardId = await repository.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
      await repository.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2025, 12, 20),
        historyTo: DateTime(2026, 2, 20),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CreditCardDetailScreen(cardId: cardId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HDFC ••5534'), findsWidgets);
      expect(find.text('Billing Cycles'), findsOneWidget);
      expect(find.textContaining('Bill Amount:'), findsWidgets);
      expect(find.text('Paid'), findsWidgets);

      await database.close();
    });
  });
}
