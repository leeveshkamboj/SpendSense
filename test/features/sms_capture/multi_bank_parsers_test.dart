import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/parsers/icici_parsers.dart';
import 'package:spendsense/features/sms_capture/parsers/axis_parsers.dart';
import 'package:spendsense/features/sms_capture/parsers/kotak_parsers.dart';

void main() {
  group('ICICI parsers', () {
    test('parses credit card expense SMS', () {
      const sms =
          'Transaction of INR 1,250.50 on ICICI Bank Credit Card XX1234 at SWIGGY on 09-07-26';

      final parsed = parseIciciCardExpenseSms(sms);

      expect(parsed!.bank, 'ICICI');
      expect(parsed.lastFourDigits, '1234');
      expect(parsed.amountPaise, 125050);
      expect(parsed.merchant, contains('SWIGGY'));
    });

    test('parses bank debit SMS', () {
      const sms =
          'ICICI Bank Acct XX5678 debited for Rs 500.00 on 09-07-26 Info UPI/merchant@upi';

      final parsed = parseIciciBankSms(sms);

      expect(parsed!.kind, BankTransactionKind.debit);
      expect(parsed.lastFourDigits, '5678');
      expect(parsed.amountPaise, 50000);
    });
  });

  group('Axis parsers', () {
    test('parses credit card expense SMS', () {
      const sms =
          'INR 320.00 spent on Axis Bank Card XX9012 at AMAZON on 09-07-26';

      final parsed = parseAxisCardExpenseSms(sms);

      expect(parsed!.bank, 'Axis');
      expect(parsed.lastFourDigits, '9012');
      expect(parsed.amountPaise, 32000);
    });

    test('parses bank credit SMS', () {
      const sms =
          'Axis Bank A/c XX3456 credited with INR 12000.00 on 09-07-26 SALARY';

      final parsed = parseAxisBankSms(sms);

      expect(parsed!.kind, BankTransactionKind.credit);
      expect(parsed.category, 'Salary');
      expect(parsed.amountPaise, 1200000);
    });
  });

  group('Kotak parsers', () {
    test('parses credit card expense SMS', () {
      const sms =
          'Rs.999.00 spent on Kotak Credit Card ending 7788 at FLIPKART on 09-07-26';

      final parsed = parseKotakCardExpenseSms(sms);

      expect(parsed!.bank, 'Kotak');
      expect(parsed.lastFourDigits, '7788');
      expect(parsed.amountPaise, 99900);
    });

    test('parses bank debit SMS', () {
      const sms =
          'Kotak Bank A/c XX1122 debited by Rs.1500 on 09-07-26 UPI-REF123';

      final parsed = parseKotakBankSms(sms);

      expect(parsed!.kind, BankTransactionKind.debit);
      expect(parsed.amountPaise, 150000);
      expect(parsed.referenceNumber, 'REF123');
    });
  });
}
