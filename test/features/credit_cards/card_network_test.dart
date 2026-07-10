import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/credit_cards/domain/card_network.dart';

void main() {
  group('CardNetwork', () {
    test('parses common spellings', () {
      expect(CardNetwork.parse('Visa'), CardNetwork.visa);
      expect(CardNetwork.parse('MASTER CARD'), CardNetwork.mastercard);
      expect(CardNetwork.parse('rupay'), CardNetwork.rupay);
      expect(CardNetwork.parse('American Express'), CardNetwork.amex);
    });

    test('returns canonical storage values', () {
      expect(
        CardNetwork.canonicalStorageValue('Mastercard'),
        'mastercard',
      );
      expect(CardNetwork.canonicalStorageValue('unknown'), isNull);
    });
  });
}
