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
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/home_widgets/presentation/widget_quick_add_sheet.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';
import 'package:spendsense/features/settings/data/app_preferences_repository.dart';

void main() {
  group('WidgetQuickAddSheet without app lock', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      final onboarding = OnboardingRepository(database);
      await onboarding.isOnboardingComplete();
      await onboarding.markOnboardingComplete();
      await CreditCardRepository(database).create(
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

    testWidgets('shows quick-add sheet even when app lock is enabled', (
      tester,
    ) async {
      final repository = AppLockRepository(
        preferences: AppPreferencesRepository(database),
        gateway: InMemoryAppLockGateway(
          biometricAuthenticateSuccess: false,
          biometricsAvailable: false,
        ),
        pinStore: InMemoryAppPinStore(),
      );
      await repository.enableWithPin('1234');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            appLockRepositoryProvider.overrideWithValue(repository),
            appLockEnabledProvider.overrideWith((ref) async => true),
            appLockGatewayProvider.overrideWithValue(
              InMemoryAppLockGateway(
                biometricAuthenticateSuccess: false,
                biometricsAvailable: false,
              ),
            ),
          ],
          child: const MaterialApp(
            home: WidgetQuickAddSheet(
              initialKind: 'expense',
              onFinished: _noop,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsNothing);
      expect(find.text('Quick add expense'), findsOneWidget);
    });
  });
}

void _noop() {}
