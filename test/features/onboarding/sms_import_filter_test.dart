import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/onboarding/sms_import_filter.dart';

void main() {
  group('SMS import filter', () {
    test('imports only messages on or after the backup date', () {
      final messages = [
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-08:16:15:20.',
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
        'Rs.199.15 spent on your SBI Credit Card ending with 8401 at ZOMATO on 10-07-26 Ref 123456',
      ];

      final filtered = filterSmsSince(
        messages,
        since: DateTime(2026, 7, 9),
      );

      expect(filtered, hasLength(2));
      expect(filtered.first, contains('2026-07-09'));
      expect(filtered.last, contains('10-07-26'));
    });
  });
}
