import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/engine/budget_alerts.dart';
import 'package:spendsense/features/budgets/engine/budget_projection.dart';

void main() {
  group('Budget alerts', () {
    test('fires thresholds at 75%, 90%, and 100%', () {
      expect(
        crossedSpendingAlertThresholds(
          spentPaise: 76000,
          limitPaise: 100000,
          previouslyCrossed: const {},
        ),
        {BudgetAlertThreshold.seventyFivePercent},
      );

      expect(
        crossedSpendingAlertThresholds(
          spentPaise: 100000,
          limitPaise: 100000,
          previouslyCrossed: const {
            BudgetAlertThreshold.seventyFivePercent,
            BudgetAlertThreshold.ninetyPercent,
          },
        ),
        {BudgetAlertThreshold.oneHundredPercent},
      );
    });

    test('does not repeat already crossed thresholds', () {
      expect(
        crossedSpendingAlertThresholds(
          spentPaise: 80000,
          limitPaise: 100000,
          previouslyCrossed: const {BudgetAlertThreshold.seventyFivePercent},
        ),
        isEmpty,
      );
    });
  });

  group('Budget projection', () {
    test('projects linear end-of-period spend from current pace', () {
      final projection = projectEndOfPeriodSpend(
        spentPaise: 10000,
        periodStart: DateTime(2026, 7, 1),
        asOf: DateTime(2026, 7, 10),
        periodEnd: DateTime(2026, 7, 31),
      );

      expect(projection, 31000);
    });
  });
}
