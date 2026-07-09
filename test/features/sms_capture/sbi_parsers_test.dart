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
  });
}
