import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/engine/due_date.dart';

void main() {
  group('Due date', () {
    test('calculates due date as bill date plus per-card offset', () {
      final dueDate = calculateDueDate(
        billDate: DateTime(2026, 2, 15),
        dueDateOffsetDays: 18,
      );

      expect(dueDate, DateTime(2026, 3, 5));
    });
  });
}
