import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/home_widgets/presentation/widget_quick_add_sheet.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('WidgetQuickAddSheet', () {
    late AppDatabase database;
    var finished = false;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      finished = false;
      final onboarding = OnboardingRepository(database);
      await onboarding.isOnboardingComplete();
      await onboarding.markOnboardingComplete();
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
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> pumpSheet(
      WidgetTester tester, {
      String initialKind = 'expense',
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            home: WidgetQuickAddSheet(
              initialKind: initialKind,
              onFinished: () => finished = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('shows expense title for expense kind', (tester) async {
      await pumpSheet(tester);
      expect(find.text('Quick add expense'), findsOneWidget);
    });

    testWidgets('shows income title for income kind', (tester) async {
      await pumpSheet(tester, initialKind: 'income');
      expect(find.text('Quick add income'), findsOneWidget);
    });

    testWidgets('cancel finishes without saving', (tester) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(finished, isTrue);
      expect(await CardTransactionRepository(database).listAll(), isEmpty);
    });
  });
}
