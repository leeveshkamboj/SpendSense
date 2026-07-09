import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';

int projectEndOfPeriodSpend({
  required int spentPaise,
  required DateTime periodStart,
  required DateTime asOf,
  required DateTime periodEnd,
}) {
  final start = DateTime(periodStart.year, periodStart.month, periodStart.day);
  final current = DateTime(asOf.year, asOf.month, asOf.day);
  final end = DateTime(periodEnd.year, periodEnd.month, periodEnd.day);

  final elapsedDays = current.difference(start).inDays + 1;
  final totalDays = end.difference(start).inDays + 1;

  if (elapsedDays <= 0 || totalDays <= 0) {
    return spentPaise;
  }

  final dailyPace = spentPaise / elapsedDays;
  return (dailyPace * totalDays).round();
}

DateTime budgetPeriodEnd({
  required DateTime periodStart,
  required Iterable<int> billDaysOfMonth,
}) {
  if (billDaysOfMonth.isEmpty) {
    final nextMonth = DateTime(periodStart.year, periodStart.month + 1, 0);
    return DateTime(nextMonth.year, nextMonth.month, nextMonth.day);
  }

  var latestEnd = periodStart;
  for (final billDay in billDaysOfMonth) {
    final cycle = billingCycleContaining(
      transactionDate: periodStart,
      billDayOfMonth: billDay,
    );
    if (!cycle.endDate.isBefore(latestEnd)) {
      latestEnd = cycle.endDate;
    }
  }

  return latestEnd;
}
