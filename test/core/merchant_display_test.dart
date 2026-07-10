import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/formatting/merchant_display.dart';

void main() {
  group('formatMerchantLabel', () {
    test('title-cases known merchants', () {
      expect(formatMerchantLabel('ZOMATO LTD'), 'Zomato Ltd');
    });

    test('maps paytm qr codes to Paytm', () {
      expect(
        formatMerchantLabel('paytmqr281005050101lvgoa6'),
        'Paytm',
      );
    });

    test('strips HDFC boilerplate from stored merchant text', () {
      expect(
        formatMerchantLabel(
          'paytmqr281005050101lvgoa6 by UPI 617991948334 On 28-06 '
          'Not You? Call 18002586161',
        ),
        'Paytm',
      );
    });

    test('maps paytm UPI handles', () {
      expect(formatMerchantLabel('paytm.s26pdgh@pty'), 'Paytm');
    });
  });
}
