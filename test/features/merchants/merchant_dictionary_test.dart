import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/merchants/engine/merchant_dictionary.dart';

void main() {
  group('Merchant dictionary', () {
    test('categorizes Zomato as Food', () {
      expect(lookupMerchantCategory('ZOMATO LTD'), 'Food');
    });

    test('categorizes Indian Oil as Fuel', () {
      expect(lookupMerchantCategory('INDIAN OIL'), 'Fuel');
    });

    test('defaults unknown merchants to Miscellaneous', () {
      expect(lookupMerchantCategory('RANDOM SHOP XYZ'), 'Miscellaneous');
    });
  });
}
