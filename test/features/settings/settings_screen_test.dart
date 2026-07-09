import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/settings/data/app_data_providers.dart';
import 'package:spendsense/features/settings/data/app_data_repository.dart';
import 'package:spendsense/features/settings/presentation/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:spendsense/core/database/database.dart';

class _FakeAppDataRepository extends AppDataRepository {
  _FakeAppDataRepository() : super(_FakeDatabase());
}

class _FakeDatabase extends AppDatabase {
  _FakeDatabase() : super(NativeDatabase.memory());
}

void main() {
  group('SettingsScreen', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBudgetsProvider.overrideWith((ref) async => []),
            appDataRepositoryProvider.overrideWithValue(
              _FakeAppDataRepository(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows grouped settings entries', (tester) async {
      await pumpScreen(tester);

      expect(find.text('App lock'), findsOneWidget);
      expect(find.text('Merchants'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('SMS senders'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('SMS senders'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('About SpendSense'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('About SpendSense'), findsOneWidget);
    });

    testWidgets('search filters settings entries', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(SearchBar), 'backup');
      await tester.pumpAndSettle();

      expect(find.text('Backup & Restore'), findsOneWidget);
      expect(find.text('Merchants'), findsNothing);
      expect(find.text('Export report'), findsNothing);
    });
  });
}
