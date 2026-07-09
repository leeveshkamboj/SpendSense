import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
          ],
          child: const SpendSenseApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows bottom navigation with six tabs', (tester) async {
      await pumpApp(tester);

      expect(find.byType(NavigationDestination), findsNWidgets(6));
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('navigates to placeholder screen when tab is tapped', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.text('Dashboard'), findsWidgets);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Transactions'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No card transactions yet'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('shows Quick Add FAB on all tabs except Settings', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Bills'),
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
