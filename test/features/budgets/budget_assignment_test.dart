import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/engine/budget_assignment.dart';

void main() {
  group('Budget assignment', () {
    test('assigns spend before bill date to current budget period', () {
      final periodStart = budgetPeriodStartForTransaction(
        transactionDate: DateTime(2026, 7, 9),
        billDayOfMonth: 15,
      );

      expect(periodStart, DateTime(2026, 6, 16));
    });

    test('assigns spend on or after bill date to next budget period', () {
      final periodStart = budgetPeriodStartForTransaction(
        transactionDate: DateTime(2026, 7, 20),
        billDayOfMonth: 15,
      );

      expect(periodStart, DateTime(2026, 7, 16));
    });

    test('uses next budget period when unified rollover is active', () {
      final periodStart = budgetPeriodStartForTransaction(
        transactionDate: DateTime(2026, 7, 10),
        billDayOfMonth: 25,
        unifiedRolloverActive: true,
      );

      expect(periodStart, DateTime(2026, 7, 26));
    });
  });
}
