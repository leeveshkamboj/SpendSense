import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/parsers/hdfc_card_expense_parser.dart';

void main() {
  group('HDFC card expense parser', () {
    test('parses Spent Rs purchase SMS from PRD', () {
      const sms =
          'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.';

      final parsed = parseHdfcCardExpenseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 41167);
      expect(parsed.merchant, 'ZOMATO LTD');
      expect(parsed.bank, 'HDFC');
      expect(parsed.lastFourDigits, '5534');
      expect(parsed.transactionAt, DateTime(2026, 7, 9, 16, 15, 20));
      expect(parsed.rawSms, sms);
    });

    test('parses multiline UPI purchase SMS from PRD', () {
      const sms = '''Txn Rs.88.00
On HDFC Bank Card 9245
At paytm.s26pdgh@pty
by UPI''';

      final parsed = parseHdfcCardExpenseSms(sms);

      expect(parsed, isNotNull);
      expect(parsed!.amountPaise, 8800);
      expect(parsed.merchant, 'paytm.s26pdgh@pty');
      expect(parsed.lastFourDigits, '9245');
    });
  });
}
