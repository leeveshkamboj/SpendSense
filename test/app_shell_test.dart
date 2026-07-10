import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/backup/data/backup_providers.dart';
import 'package:spendsense/features/backup/presentation/data_recovery_gate.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_providers.dart';
import 'package:spendsense/app/app.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';

void main() {
  group('App shell', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            onboardingCompleteProvider.overrideWith((ref) async => true),
            smsPermissionStateProvider.overrideWith(
              (ref) async => SmsPermissionState.granted,
            ),
            notificationPermissionStateProvider.overrideWith(
              (ref) async => NotificationPermissionState.granted,
            ),
            homeWidgetSyncProvider.overrideWith((ref) async {}),
            autoBackupSyncProvider.overrideWith((ref) async {}),
            databaseHealthProvider.overrideWith((ref) async => true),
          ],
          child: const SpendSenseApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows bottom navigation with five icon-only tabs', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.dashboard),
        ),
        findsOneWidget,
      );
    });

    testWidgets('navigates when a tab icon is tapped', (tester) async {
      await pumpApp(tester);

      expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.receipt_long_outlined),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Transactions'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('opens quick add sheet from FAB', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('shows Quick Add FAB only on tabs without a local FAB', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.account_balance_wallet_outlined),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add card'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.receipt_long_outlined),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.request_page_outlined),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('uses Material 3 with system light/dark theme', (tester) async {
      await pumpApp(tester);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(materialApp.darkTheme?.useMaterial3, isTrue);
    });
  });
}
