import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/linking/data/linking_repository.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('SmsCaptureService', () {
    const spentSms =
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.';

    late AppDatabase database;
    late SmsCaptureService service;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      service = SmsCaptureService(
        creditCards: CreditCardRepository(database),
        cardTransactions: CardTransactionRepository(database),
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: CreditCardRepository(database),
          cardTransactions: CardTransactionRepository(database),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('auto-creates card and captures HDFC expense', () async {
      final result = await service.processSms(spentSms);
      expect(result, SmsCaptureResult.captured);
      expect((await CardTransactionRepository(database).listAll()).length, 1);
    });

    test('auto-creates account and captures SBI bank debit', () async {
      const sms =
          'Dear UPI user A/C X0428 debited by 25000.00 on 09-07-26 to MERCHANT Ref 987654';

      final result = await service.processSms(sms);

      expect(result, SmsCaptureResult.captured);
      final accounts = await BankAccountRepository(database).listActive();
      expect(accounts.single.nickname, 'SBI ••0428');
      expect(
        (await BankAccountTransactionRepository(database).listAll()).single.kind,
        'debit',
      );
    });

    test('assigns salary category to credit SMS', () async {
      const sms =
          'Axis Bank A/c XX3456 credited with INR 12000.00 on 09-07-26 SALARY';

      await service.processSms(sms);

      final tx = (await BankAccountTransactionRepository(database).listAll())
          .single;
      expect(tx.category, 'Salary');
    });

    test('assigns interest category to credit SMS', () async {
      const sms =
          'Axis Bank A/c XX3456 credited with INR 250.00 on 09-07-26 INTEREST';

      await service.processSms(sms);

      final tx = (await BankAccountTransactionRepository(database).listAll())
          .single;
      expect(tx.category, 'Investment');
    });

    test('stores resolved location on captured card expense', () async {
      const location = 'geo:12.9716,77.5946|Bengaluru';
      service = SmsCaptureService(
        creditCards: CreditCardRepository(database),
        cardTransactions: CardTransactionRepository(database),
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: CreditCardRepository(database),
          cardTransactions: CardTransactionRepository(database),
        ),
        resolveLocation: () async => location,
      );

      await service.processSms(spentSms);

      final tx = (await CardTransactionRepository(database).listAll()).single;
      expect(tx.location, location);
    });

    test('stores resolved location on captured bank debit', () async {
      const location = 'geo:19.0760,72.8777|Mumbai';
      const sms =
          'Dear UPI user A/C X0428 debited by 25000.00 on 09-07-26 to MERCHANT Ref 987654';
      service = SmsCaptureService(
        creditCards: CreditCardRepository(database),
        cardTransactions: CardTransactionRepository(database),
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        linking: LinkingRepository(
          database: database,
          creditCards: CreditCardRepository(database),
          cardTransactions: CardTransactionRepository(database),
        ),
        resolveLocation: () async => location,
      );

      await service.processSms(sms);

      final tx =
          (await BankAccountTransactionRepository(database).listAll()).single;
      expect(tx.location, location);
    });
  });
}
