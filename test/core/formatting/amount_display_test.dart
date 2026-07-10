import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/formatting/amount_display.dart';

void main() {
  group('formatPaise', () {
    test('formats whole rupee amounts with Indian grouping', () {
      expect(formatPaise(50000), '₹500');
      expect(formatPaise(100000), '₹1,000');
      expect(formatPaise(1000000), '₹10,000');
      expect(formatPaise(10000000), '₹1,00,000');
      expect(formatPaise(100000000), '₹10,00,000');
      expect(formatPaise(1000000000), '₹1,00,00,000');
    });

    test('formats fractional rupee amounts with Indian grouping', () {
      expect(formatPaise(41167), '₹411.67');
      expect(formatPaise(1234567), '₹12,345.67');
    });
  });
}
