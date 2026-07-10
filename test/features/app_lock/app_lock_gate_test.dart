import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/app_lock/app_lock_gateway.dart';
import 'package:spendsense/features/app_lock/app_lock_providers.dart';
import 'package:spendsense/features/app_lock/app_lock_repository.dart';
import 'package:spendsense/features/app_lock/app_pin_store.dart';
import 'package:spendsense/features/app_lock/presentation/app_lock_gate.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';
import 'package:spendsense/features/settings/data/app_preferences_repository.dart';

void main() {
  group('AppLockGate', () {
    late AppDatabase database;
    late InMemoryAppLockGateway gateway;
    late InMemoryAppPinStore pinStore;
    late AppLockRepository repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      gateway = InMemoryAppLockGateway(
        biometricAuthenticateSuccess: false,
        biometricsAvailable: true,
      );
      pinStore = InMemoryAppPinStore();
      repository = AppLockRepository(
        preferences: AppPreferencesRepository(database),
        gateway: gateway,
        pinStore: pinStore,
      );
      await repository.enableWithPin('1234');
      await repository.setBiometricEnabled(true);
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> pumpGate(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            appLockGatewayProvider.overrideWithValue(gateway),
            appLockRepositoryProvider.overrideWithValue(repository),
            appLockEnabledProvider.overrideWith((ref) async => true),
          ],
          child: const MaterialApp(
            home: AppLockGate(
              child: Scaffold(body: Text('unlocked-content')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('stays unlocked after inactive/paused lifecycle events', (
      tester,
    ) async {
      gateway.biometricAuthenticateSuccess = true;
      await pumpGate(tester);

      expect(find.text('unlocked-content'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text('unlocked-content'), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('does not re-prompt biometric on resume after cancel', (
      tester,
    ) async {
      await pumpGate(tester);

      expect(gateway.biometricAuthenticateCalls, 1);
      expect(find.text('Welcome back'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(gateway.biometricAuthenticateCalls, 1);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('unlocks with PIN after biometric is declined', (tester) async {
      await pumpGate(tester);

      expect(find.text('Welcome back'), findsOneWidget);

      for (final digit in '1234'.split('')) {
        await tester.tap(find.text(digit).last);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('unlocked-content'), findsOneWidget);
    });

    testWidgets('fingerprint key reopens biometric without Overlay error', (
      tester,
    ) async {
      FlutterErrorDetails? firstError;
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        firstError ??= details;
        previous?.call(details);
      };

      try {
        await pumpGate(tester);

        expect(find.byIcon(Icons.fingerprint), findsOneWidget);
        expect(gateway.biometricAuthenticateCalls, 1);

        await tester.tap(find.byIcon(Icons.fingerprint));
        await tester.pumpAndSettle();

        expect(gateway.biometricAuthenticateCalls, 2);
        expect(firstError, isNull);
      } finally {
        FlutterError.onError = previous;
      }
    });

    testWidgets('lock screen works inside MaterialApp.builder without Overlay crash', (
      tester,
    ) async {
      FlutterErrorDetails? firstError;
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        firstError ??= details;
        previous?.call(details);
      };

      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(database),
              appLockGatewayProvider.overrideWithValue(gateway),
              appLockRepositoryProvider.overrideWithValue(repository),
              appLockEnabledProvider.overrideWith((ref) async => true),
            ],
            child: MaterialApp(
              builder: (context, child) {
                return AppLockGate(child: child ?? const SizedBox.shrink());
              },
              home: const Scaffold(body: Text('home')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.byIcon(Icons.fingerprint), findsOneWidget);
        expect(find.text('No Overlay widget found'), findsNothing);
        expect(firstError, isNull);

        // Tooltip-using control must resolve against the lock Overlay.
        await tester.tap(find.byIcon(Icons.fingerprint));
        await tester.pumpAndSettle();
        expect(gateway.biometricAuthenticateCalls, greaterThanOrEqualTo(2));
        expect(firstError, isNull);
      } finally {
        FlutterError.onError = previous;
      }
    });
  });
}
