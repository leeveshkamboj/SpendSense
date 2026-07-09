import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/otp_filter.dart';
import 'package:spendsense/features/sms_capture/unparsed_sms_notifier.dart';

void main() {
  group('OTP filter', () {
    test('ignores SMS containing OTP keywords', () {
      expect(
        isOtpSms('Your OTP for HDFC login is 482910. Do not share.'),
        isTrue,
      );
      expect(
        isOtpSms('One Time Password: 123456 valid for 3 minutes'),
        isTrue,
      );
    });

    test('allows transaction SMS through', () {
      expect(
        isOtpSms(
          'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
        ),
        isFalse,
      );
    });
  });

  group('Unparsed SMS notifier', () {
    test('flags SMS with transaction keywords when parser fails', () {
      expect(
        shouldNotifyManualAdd(
          'Your A/C was debited by Rs.500 at UNKNOWN FORMAT BANK',
        ),
        isTrue,
      );
    });

    test('silently ignores SMS without transaction keywords', () {
      expect(
        shouldNotifyManualAdd('Happy birthday from your bank!'),
        isFalse,
      );
    });
  });
}
