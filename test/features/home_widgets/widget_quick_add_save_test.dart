import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/home_widgets/presentation/widget_quick_add_save.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('saveWidgetQuickAdd', () {
    late AppDatabase database;
    late ProviderContainer container;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
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

      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
    });

    tearDown(() {
      container.dispose();
      return database.close();
    });

    test('inserts a manual expense', () async {
      final result = await saveWidgetQuickAdd(
        read: container.read,
        widgetRef: null,
        request: const WidgetQuickAddSaveRequest(
          kind: 'expense',
          amountText: '123.45',
          merchantText: 'Coffee',
        ),
      );

      expect(result, isA<WidgetQuickAddSaveSuccess>());
      final txs = await CardTransactionRepository(database).listAll();
      expect(txs, hasLength(1));
      expect(txs.single.amountPaise, 12345);
      expect(txs.single.merchant, 'Coffee');
      expect(txs.single.source, 'Manual');
    });

    test('rejects invalid amount', () async {
      final result = await saveWidgetQuickAdd(
        read: container.read,
        widgetRef: null,
        request: const WidgetQuickAddSaveRequest(
          kind: 'expense',
          amountText: '',
          merchantText: 'Coffee',
        ),
      );

      expect(
        result,
        isA<WidgetQuickAddSaveFailure>().having(
          (failure) => failure.message,
          'message',
          'Enter a valid amount',
        ),
      );
    });
  });
}
