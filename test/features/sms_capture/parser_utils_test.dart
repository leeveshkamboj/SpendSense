import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

void main() {
  group('deunicodeSms', () {
    test('maps mathematical sans-serif letters to ascii', () {
      const fancy = '𝖲𝖡𝖨 𝖢𝗋𝖾𝖽𝗂𝗍 𝖢𝖺𝗋𝖽';

      expect(deunicodeSms(fancy), 'SBI Credit Card');
    });
  });

  group('parseSmsDate', () {
    test('maps compact month dates', () {
      expect(parseSmsDate('12May26'), DateTime(2026, 5, 12));
      expect(parseSmsDate('09Jun26'), DateTime(2026, 6, 9));
    });
  });
}
