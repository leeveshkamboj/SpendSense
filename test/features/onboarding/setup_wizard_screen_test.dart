import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/budgets/presentation/budget_settings_screen.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_configure_screen.dart';
import 'package:spendsense/features/onboarding/presentation/setup_wizard_screen.dart';

void main() {
  testWidgets('setup wizard shows detected credit cards to configure', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = CreditCardRepository(database);
    await repository.create(
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
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const SetupWizardScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configure'), findsOneWidget);
    expect(find.text('HDFC ••5534'), findsNWidgets(2));
    expect(find.text('Continue to dashboard'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue to dashboard')).onPressed,
      isNull,
    );

    await database.close();
  });

  testWidgets('setup wizard opens configure screen for detected card', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = CreditCardRepository(database);
    await repository.create(
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
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const SetupWizardScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configure'));
    await tester.pumpAndSettle();

    expect(find.text('Configure billing'), findsOneWidget);

    await database.close();
  });

  testWidgets('setup wizard opens add card and budget screens', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const SetupWizardScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add another credit card'));
    await tester.pumpAndSettle();
    expect(find.byType(CreditCardSetupScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set monthly budget (optional)'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetSettingsScreen), findsOneWidget);

    await database.close();
  });
}
