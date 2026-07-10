import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/sbi_parsers.dart';

void main() {
  group('SBI card parser', () {
    test('parses e-Mandate expense from PRD', () {
      const sms =
          'Trxn. of Rs.499.00 at JIOHOTSTAR on SBI Card 8401 on 09-07-26';

      final parsed = parseSbiCardExpenseSms(sms);

      expect(parsed, isA<ParsedCardExpense>());
      expect(parsed!.amountPaise, 49900);
      expect(parsed.merchant, contains('JIOHOTSTAR'));
      expect(parsed.bank, 'SBI');
    });

    test('parses UPI card expense from PRD', () {
      const sms =
          'Rs.199.15 spent on your SBI Credit Card ending with 8401 at ZOMATO on 09-07-26 Ref 123456';

      final parsed = parseSbiCardExpenseSms(sms);

      expect(parsed!.amountPaise, 19915);
      expect(parsed.lastFourDigits, '8401');
      expect(parsed.merchant, contains('ZOMATO'));
      expect(parsed.referenceNumber, '123456');
    });

    test('parses UPI card expense with stylized unicode and comma amount', () {
      const sms =
          'Rs.2,000.00 𝗌𝗉𝖾𝗇𝗍 𝗈𝗇 𝗒𝗈𝗎𝗋 𝖲𝖡𝖨 𝖢𝗋𝖾𝖽𝗂𝗍 𝖢𝖺𝗋𝖽 𝖾𝗇𝖽𝗂𝗇𝗀 with 8401 at MAMTARANI on 25-05-26 via UPI (Ref No. 614547544975). 𝖳𝗋𝗑𝗇. 𝗇𝗈𝗍 𝖽𝗈𝗇𝖾 𝖻𝗒 𝗒𝗈𝗎? 𝖱𝖾𝗉𝗈𝗋𝗍 𝖺𝗍 https://sbicard.com/Dispute';

      final parsed = parseSbiCardExpenseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 200000);
      expect(parsed.lastFourDigits, '8401');
      expect(parsed.merchant, 'MAMTARANI');
      expect(parsed.referenceNumber, '614547544975');
      expect(parsed.transactionAt, DateTime(2026, 5, 25));
    });

    test('parses e-Mandate debit from real inbox SMS', () {
      const sms =
          'Trxn. of Rs.499.00 at JIOHOTSTAR against e-Mandate registered by you at merchant has been debited from your credit card ending 8401 on 07-07-26';

      final parsed = parseSbiCardExpenseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 49900);
      expect(parsed.lastFourDigits, '8401');
      expect(parsed.merchant, contains('JIOHOTSTAR'));
    });

    test('ignores declined SBI card transactions', () {
      const sms =
          'Trxn. of Rs.75.00 at CANVAPAAAAHFKX2XUBSW on 25-05-26 with your credit card ending 8401 was declined';

      expect(parseSbiCardExpenseSms(sms), isNull);
    });
  });

  group('SBI bank parser', () {
    test('parses UPI debit from PRD', () {
      const sms =
          'Dear UPI user A/C X0428 debited by 25000.00 on 09-07-26 to MERCHANT Ref 987654';

      final parsed = parseSbiBankSms(sms);

      expect(parsed, isA<ParsedBankTransaction>());
      expect(parsed!.kind, BankTransactionKind.debit);
      expect(parsed.amountPaise, 2500000);
      expect(parsed.lastFourDigits, '0428');
      expect(parsed.beneficiary, contains('MERCHANT'));
      expect(parsed.referenceNumber, '987654');
    });

    test('parses account credit from PRD', () {
      const sms =
          'Dear SBI User, your A/c X0428 credited by Rs.6500 on 09-07-26';

      final parsed = parseSbiBankSms(sms);

      expect(parsed!.kind, BankTransactionKind.credit);
      expect(parsed.amountPaise, 650000);
      expect(parsed.lastFourDigits, '0428');
    });

    test('parses UPI debit with compact date from real inbox SMS', () {
      const sms =
          'Dear UPI user A/C X0428 debited by 16.00 on date 12May26 trf to Rekha Devi Refno 649800047292 If not done by you';

      final parsed = parseSbiBankSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.kind, BankTransactionKind.debit);
      expect(parsed.amountPaise, 1600);
      expect(parsed.beneficiary, contains('Rekha Devi'));
      expect(parsed.referenceNumber, '649800047292');
      expect(parsed.transactionAt, DateTime(2026, 5, 12));
    });

    test('parses hyphenated account credit from real inbox SMS', () {
      const sms =
          'Dear SBI User, your A/c X0428-credited by Rs.6500 on 09Jun26 transfer from GAUTAM G KALRO Ref No 616';

      final parsed = parseSbiBankSms(sms);

      expect(parsed!.kind, BankTransactionKind.credit);
      expect(parsed.amountPaise, 650000);
      expect(parsed.transactionAt, DateTime(2026, 6, 9));
    });

    test('parses masked account credit from real inbox SMS', () {
      const sms =
          'Dear Customer, Your a/c no. XXXXXXXX0428 is credited by Rs.7000.00 on 11-05-26 by a/c linked to mobile';

      final parsed = parseSbiBankSms(sms);

      expect(parsed!.kind, BankTransactionKind.credit);
      expect(parsed.amountPaise, 700000);
      expect(parsed.lastFourDigits, '0428');
    });
  });
}
