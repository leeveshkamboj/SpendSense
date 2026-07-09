import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_generation.dart';

void main() {
  group('Cycle generation', () {
    test('generates consecutive cycles across a historical date range', () {
      final cycles = generateBillingCyclesBetween(
        from: DateTime(2025, 12, 20),
        to: DateTime(2026, 2, 20),
        billDayOfMonth: 15,
      );

      expect(cycles.length, 3);
      expect(cycles[0].startDate, DateTime(2025, 12, 16));
      expect(cycles[0].endDate, DateTime(2026, 1, 15));
      expect(cycles[1].startDate, DateTime(2026, 1, 16));
      expect(cycles[1].endDate, DateTime(2026, 2, 15));
      expect(cycles[2].startDate, DateTime(2026, 2, 16));
      expect(cycles[2].endDate, DateTime(2026, 3, 15));
    });
  });
}
