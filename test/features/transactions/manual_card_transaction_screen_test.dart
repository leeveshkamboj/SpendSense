import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/presentation/manual_card_transaction_screen.dart';

void main() {
  group('ManualCardTransactionScreen', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
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
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> pumpScreen(
      WidgetTester tester, {
      required String initialLocation,
    }) async {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/transactions/manual',
            builder: (context, state) => ManualCardTransactionScreen(
              initialKind: state.uri.queryParameters['kind'],
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('preselects expense type when opened from quick add widget', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        initialLocation: '/transactions/manual?kind=expense',
      );

      expect(find.text('Add transaction'), findsOneWidget);
      expect(
        tester.widget<DropdownButtonFormField<String>>(
          find.byWidgetPredicate(
            (widget) =>
                widget is DropdownButtonFormField<String> &&
                widget.decoration?.labelText == 'Type',
          ),
        ).initialValue,
        'expense',
      );
    });

    testWidgets('preselects refund type when opened from quick add income widget', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        initialLocation: '/transactions/manual?kind=refund',
      );

      expect(
        tester.widget<DropdownButtonFormField<String>>(
          find.byWidgetPredicate(
            (widget) =>
                widget is DropdownButtonFormField<String> &&
                widget.decoration?.labelText == 'Type',
          ),
        ).initialValue,
        'refund',
      );
    });
  });
}
