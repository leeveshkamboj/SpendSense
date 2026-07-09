import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';

void main() {
  group('Cycle assignment', () {
    test('assigns expense to cycle spanning day after bill date through bill date', () {
      final period = billingCycleContaining(
        transactionDate: DateTime(2026, 1, 20),
        billDayOfMonth: 15,
      );

      expect(period.startDate, DateTime(2026, 1, 16));
      expect(period.endDate, DateTime(2026, 2, 15));
    });

    test('assigns transaction before bill day to previous cycle', () {
      final period = billingCycleContaining(
        transactionDate: DateTime(2026, 1, 10),
        billDayOfMonth: 15,
      );

      expect(period.startDate, DateTime(2025, 12, 16));
      expect(period.endDate, DateTime(2026, 1, 15));
    });

    test('assigns transaction on bill day to cycle ending that day', () {
      final period = billingCycleContaining(
        transactionDate: DateTime(2026, 2, 15),
        billDayOfMonth: 15,
      );

      expect(period.startDate, DateTime(2026, 1, 16));
      expect(period.endDate, DateTime(2026, 2, 15));
    });
  });
}
