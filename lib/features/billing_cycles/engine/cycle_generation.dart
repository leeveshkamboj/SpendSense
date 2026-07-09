import 'package:spendsense/features/billing_cycles/domain/billing_cycle_period.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';

/// Generates consecutive billing cycle periods from [from] through [to].
List<BillingCyclePeriod> generateBillingCyclesBetween({
  required DateTime from,
  required DateTime to,
  required int billDayOfMonth,
}) {
  if (to.isBefore(from)) {
    return [];
  }

  final periods = <BillingCyclePeriod>[];
  var cursor = from;

  while (!cursor.isAfter(to)) {
    final period = billingCycleContaining(
      transactionDate: cursor,
      billDayOfMonth: billDayOfMonth,
    );

    final alreadyAdded = periods.any(
      (existing) =>
          existing.startDate == period.startDate &&
          existing.endDate == period.endDate,
    );

    if (!alreadyAdded) {
      periods.add(period);
    }

    cursor = DateTime(
      period.endDate.year,
      period.endDate.month,
      period.endDate.day + 1,
    );
  }

  return periods;
}
