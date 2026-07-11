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
  group('Linking capture integration', () {
    late AppDatabase database;
    late SmsCaptureService service;
    late CreditCardRepository creditCards;
    late CardTransactionRepository cardTransactions;
    late LinkingRepository linking;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      cardTransactions = CardTransactionRepository(database);
      linking = LinkingRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: cardTransactions,
      );
      service = SmsCaptureService(
        creditCards: creditCards,
        cardTransactions: cardTransactions,
        bankAccounts: BankAccountRepository(database),
        bankAccountTransactions: BankAccountTransactionRepository(database),
        merchants: MerchantRepository(database),
        tags: TagRepository(database),
        seenSms: SeenSmsRepository(database),
        linking: linking,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('pairs bank transfer debit and credit across accounts', () async {
      const debitSms =
          'Dear UPI user A/C X0428 debited by 5000.00 on 09-07-26 to SELF Ref 111';
      const creditSms =
          'A/c X9876 credited by Rs.5000.00 on 09-07-26';

      await service.processSms(debitSms);
      await service.processSms(creditSms);

      final links = await database.select(database.transactionLinks).get();
      expect(links, hasLength(1));
      expect(links.single.kind, 'transfer');

      final bankTransactions =
          await BankAccountTransactionRepository(database).listAll();
      expect(
        bankTransactions.every((tx) => tx.category == 'Transfer'),
        isTrue,
      );
    });

    test('captures refund linked to original expense billing cycle', () async {
      const expenseSms =
          'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.';
      const refundSms =
          'Credit of Rs.411.67 received on HDFC Bank Card 5534 for ZOMATO LTD On 2026-07-10';

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

      await service.processSms(expenseSms);
      final expense = (await cardTransactions.listAll())
          .firstWhere((tx) => tx.kind == 'expense');

      await service.processSms(refundSms);
      final refund = (await cardTransactions.listAll())
          .firstWhere((tx) => tx.kind == 'refund');

      expect(refund.billingCycleId, expense.billingCycleId);
      final links = await database.select(database.transactionLinks).get();
      expect(links.single.kind, 'refund');
      expect(links.single.linkedCardTransactionId, expense.id);
    });

    test('assigns card payment to unpaid cycle and links bank debit', () async {
      const paymentSms =
          'Payment of Rs.5000.00 received towards HDFC Bank Card 5534 On 2026-03-10';
      const bankDebitSms =
          'Dear UPI user A/C X0428 debited by 5000.00 on 10-03-26 towards HDFC credit card 5534';

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
      final billingCycleId = await creditCards.findBillingCycleIdForTransaction(
        cardId: cardId,
        transactionAt: DateTime(2026, 2, 10),
      );
      await cardTransactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billingCycleId,
          kind: 'expense',
          amountPaise: 500000,
          merchant: 'SHOP',
          transactionAt: DateTime(2026, 2, 10),
          source: 'Manual',
        ),
      );

      await service.processSms(paymentSms);
      await service.processSms(bankDebitSms);

      final payment = (await cardTransactions.listAll())
          .firstWhere((tx) => tx.kind == 'card_payment');
      expect(payment.billingCycleId, isNotNull);

      final links = await database.select(database.transactionLinks).get();
      expect(links.single.kind, 'card_payment');
    });
  });
}
