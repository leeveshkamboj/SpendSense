import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/settings/data/app_data_providers.dart';
import 'package:spendsense/features/settings/data/app_data_repository.dart';
import 'package:spendsense/features/settings/presentation/settings_screen.dart';

class _FakeAppDataRepository extends AppDataRepository {
  _FakeAppDataRepository() : super(_FakeDatabase());

  bool deleteCalled = false;

  @override
  Future<void> deleteAllData() async {
    deleteCalled = true;
  }
}

class _FakeDatabase extends AppDatabase {
  _FakeDatabase() : super(NativeDatabase.memory());
}

void main() {
  group('Settings danger zone', () {
    testWidgets('delete all data prompts to back up first', (tester) async {
      final repository = _FakeAppDataRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBudgetsProvider.overrideWith((ref) async => []),
            appDataRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Delete all data'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete all data'));
      await tester.pumpAndSettle();

      expect(find.textContaining('backup'), findsWidgets);
      expect(find.text('Back up first'), findsOneWidget);
      expect(find.text('Delete anyway'), findsOneWidget);
    });

    testWidgets('delete anyway wipes data after confirmation', (tester) async {
      final repository = _FakeAppDataRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBudgetsProvider.overrideWith((ref) async => []),
            appDataRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Delete all data'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete all data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete anyway'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(repository.deleteCalled, isTrue);
    });
  });
}
