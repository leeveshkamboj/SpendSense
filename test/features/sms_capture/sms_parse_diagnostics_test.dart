import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/sms_parse_diagnostics.dart';

void main() {
  group('diagnoseSmsParse', () {
    test('parses stylized SBI unicode card expense', () {
      const sms =
          'Rs.2,000.00 𝗌𝗉𝖾𝗇𝗍 𝗈𝗇 𝗒𝗈𝗎𝗋 𝖲𝖡𝖨 𝖢𝗋𝖾𝖽𝗂𝗍 𝖢𝖺𝗋𝖽 𝖾𝗇𝖽𝗂𝗇𝗀 with 8401 at MAMTARANI on 25-05-26 via UPI (Ref No. 614547544975).';

      final diagnostic = diagnoseSmsParse(sms);

      expect(diagnostic.outcome, 'parsed_card_expense');
      expect(diagnostic.parserName, 'sbi_card_expense');
      expect(diagnostic.bank, 'SBI');
      expect(diagnostic.lastFourDigits, '8401');
      expect(diagnostic.amountPaise, 200000);
      expect(diagnostic.merchant, 'MAMTARANI');
      expect(diagnostic.normalizedChanged, isTrue);
    });

    test('reports otp filter', () {
      const sms = 'Your OTP for SBI Card is 123456';

      final diagnostic = diagnoseSmsParse(sms);

      expect(diagnostic.outcome, 'skipped_otp');
    });

    test('reports no parser match for unrelated SMS', () {
      const sms = 'Your package has been delivered';

      final diagnostic = diagnoseSmsParse(sms);

      expect(diagnostic.outcome, 'no_parser_match');
    });
  });
}
