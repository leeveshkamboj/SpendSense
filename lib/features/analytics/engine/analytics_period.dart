import 'package:spendsense/features/budgets/engine/budget_assignment.dart';

DateTime previousBudgetPeriodStart({
  required DateTime currentPeriodStart,
  required Iterable<CardBillingState> cards,
  required DateTime asOf,
}) {
  final configured = cards.where((card) => card.billDayOfMonth != null).toList();
  if (configured.isEmpty) {
    return DateTime(currentPeriodStart.year, currentPeriodStart.month - 1, 1);
  }

  var anchor = DateTime(
    currentPeriodStart.year,
    currentPeriodStart.month,
    currentPeriodStart.day - 1,
  );

  for (var step = 0; step < 31; step++) {
    final rollover = isUnifiedRolloverActive(asOf: anchor, cards: configured);
    final starts = configured
        .map(
          (card) => budgetPeriodStartForTransaction(
            transactionDate: anchor,
            billDayOfMonth: card.billDayOfMonth!,
            unifiedRolloverActive: rollover,
          ),
        )
        .toList();
    final candidate = starts.reduce((a, b) => a.isAfter(b) ? a : b);
    if (!_sameDay(candidate, currentPeriodStart)) {
      return candidate;
    }
    anchor = anchor.subtract(const Duration(days: 1));
  }

  return DateTime(currentPeriodStart.year, currentPeriodStart.month - 1, 1);
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatAnalyticsPeriodLabel(DateTime start) {
  return '${start.day.toString().padLeft(2, '0')}/'
      '${start.month.toString().padLeft(2, '0')}/'
      '${start.year}';
}

String formatBillingCycleLabel(DateTime start, DateTime end) {
  return '${formatAnalyticsPeriodLabel(start)} – ${formatAnalyticsPeriodLabel(end)}';
}
