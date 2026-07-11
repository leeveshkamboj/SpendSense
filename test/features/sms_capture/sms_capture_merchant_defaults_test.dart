import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/linking/data/linking_repository.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/sms_capture/data/seen_sms_repository.dart';

void main() {
  group('SmsCaptureService merchant defaults', () {
    const spentSms =
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.';

    late AppDatabase database;
    late SmsCaptureService service;
    late MerchantRepository merchants;
    late TagRepository tags;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      merchants = MerchantRepository(database);
      tags = TagRepository(database);
      service = SmsCaptureService(
        creditCards: CreditCardRepository(database),
        cardTransactions: CardTransactionRepository(database),
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: merchants,
        tags: tags,
        seenSms: SeenSmsRepository(database),
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

    test('auto-adds merchant and assigns dictionary category on capture', () async {
      final result = await service.processSms(spentSms);

      expect(result, SmsCaptureResult.captured);
      final transactions =
          await CardTransactionRepository(database).listAll();
      expect(transactions.single.category, 'Food');
      expect((await merchants.listAll()).single.rawName, 'ZOMATO LTD');
    });

    test('applies user merchant category override on capture', () async {
      await merchants.updateDefaults(
        rawName: 'ZOMATO LTD',
        defaultCategory: 'Shopping',
      );

      await service.processSms(spentSms);

      final transactions =
          await CardTransactionRepository(database).listAll();
      expect(transactions.single.category, 'Shopping');
    });

    test('applies merchant default tags on capture', () async {
      await merchants.updateDefaults(
        rawName: 'ZOMATO LTD',
        tagNames: ['Personal'],
      );

      await service.processSms(spentSms);

      final txId =
          (await CardTransactionRepository(database).listAll()).single.id;
      expect(await tags.listForCardTransaction(txId), ['Personal']);
    });
  });
}
