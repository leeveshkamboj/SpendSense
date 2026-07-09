import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_credit.dart';
import 'package:spendsense/features/sms_capture/parsers/hdfc_card_credit_parser.dart';

void main() {
  group('HDFC card credit parser', () {
    test('parses refund SMS', () {
      const sms =
          'Credit of Rs.411.67 received on HDFC Bank Card 5534 for ZOMATO LTD On 2026-07-10';

      final parsed = parseHdfcCardCreditSms(sms);

      expect(parsed!.kind, ParsedCardCreditKind.refund);
      expect(parsed.amountPaise, 41167);
      expect(parsed.merchant, 'ZOMATO LTD');
    });

    test('parses card payment received SMS', () {
      const sms =
          'Payment of Rs.5000.00 received towards HDFC Bank Card 5534 On 2026-07-10';

      final parsed = parseHdfcCardCreditSms(sms);

      expect(parsed!.kind, ParsedCardCreditKind.cardPayment);
      expect(parsed.amountPaise, 500000);
    });
  });
}
