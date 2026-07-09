import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/app_lock/app_lock_gateway.dart';
import 'package:spendsense/features/app_lock/app_lock_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/settings/data/app_preferences_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/app_lock/app_pin_store.dart';

class _MemoryStorage extends InMemoryAppPinStore {}

void main() {
  group('Archive and danger zone repositories', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late BankAccountRepository bankAccounts;
    late CardTransactionRepository transactions;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      bankAccounts = BankAccountRepository(database);
      transactions = CardTransactionRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('archives and restores credit cards', () async {
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      await creditCards.archive(cardId);

      expect(await creditCards.listActive(), isEmpty);
      expect(await creditCards.listArchived(), hasLength(1));

      await creditCards.unarchive(cardId);
      expect(await creditCards.listActive(), hasLength(1));
    });

    test('permanently deletes card and transactions', () async {
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
      final cycle = (await creditCards.listCycles(cardId)).first;
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: cycle.id,
          kind: 'expense',
          amountPaise: 1000,
          merchant: 'ZOMATO',
          transactionAt: DateTime(2026, 7, 9),
          source: 'manual',
        ),
      );

      await creditCards.deletePermanently(cardId);

      expect(await creditCards.listActive(), isEmpty);
      expect(await transactions.listForCard(cardId), isEmpty);
    });
  });

  group('AppLockRepository', () {
    late AppDatabase database;
    late AppLockRepository repository;
    late InMemoryAppLockGateway gateway;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      gateway = InMemoryAppLockGateway();
      repository = AppLockRepository(
        preferences: AppPreferencesRepository(database),
        gateway: gateway,
        pinStore: _MemoryStorage(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('stores and verifies PIN', () async {
      await repository.enableWithPin('1234');

      expect(await repository.isEnabled(), isTrue);
      expect(await repository.verifyPin('1234'), isTrue);
      expect(await repository.verifyPin('0000'), isFalse);
    });

    test('resets PIN after device credential verification', () async {
      await repository.enableWithPin('1234');

      final reset = await repository.resetPinWithDeviceCredential('5678');

      expect(reset, isTrue);
      expect(gateway.authenticateCalls, 1);
      expect(await repository.verifyPin('5678'), isTrue);
    });
  });
}
