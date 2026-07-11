import 'package:spendsense/core/database/database.dart';

/// Which billing cycle(s) to show on the Transactions tab.
sealed class TransactionCycleFilter {
  const TransactionCycleFilter();

  static const current = CurrentTransactionCycleFilter();
  static const previous = PreviousTransactionCycleFilter();
}

final class CurrentTransactionCycleFilter extends TransactionCycleFilter {
  const CurrentTransactionCycleFilter();

  @override
  bool operator ==(Object other) => other is CurrentTransactionCycleFilter;

  @override
  int get hashCode => 0;
}

final class PreviousTransactionCycleFilter extends TransactionCycleFilter {
  const PreviousTransactionCycleFilter();

  @override
  bool operator ==(Object other) => other is PreviousTransactionCycleFilter;

  @override
  int get hashCode => 1;
}

/// Cycles whose [BillingCycle.endDate] falls in [year]/[month] (bill month).
final class PeriodTransactionCycleFilter extends TransactionCycleFilter {
  const PeriodTransactionCycleFilter({
    required this.year,
    required this.month,
  });

  final int year;
  final int month;

  @override
  bool operator ==(Object other) =>
      other is PeriodTransactionCycleFilter &&
      other.year == year &&
      other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

class TransactionCycleFilterOption {
  const TransactionCycleFilterOption({
    required this.filter,
    required this.label,
  });

  final TransactionCycleFilter filter;
  final String label;
}

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String formatCyclePeriodLabel(int year, int month) {
  return '${_monthNames[month - 1]} $year cycle';
}

/// Builds filter dropdown options: Current, Last, then older bill months.
List<TransactionCycleFilterOption> buildTransactionCycleFilterOptions({
  required List<BillingCycle> currentCycles,
  required List<BillingCycle> allCycles,
}) {
  final currentIds = currentCycles.map((cycle) => cycle.id).toSet();
  final previousIds = <int>{};
  final previousPeriods = <(int, int)>{};
  final currentPeriods = <(int, int)>{};

  for (final cycle in currentCycles) {
    currentPeriods.add((cycle.endDate.year, cycle.endDate.month));
  }

  final byCard = <int, List<BillingCycle>>{};
  for (final cycle in allCycles) {
    byCard.putIfAbsent(cycle.creditCardId, () => []).add(cycle);
  }
  for (final cycles in byCard.values) {
    cycles.sort((a, b) => b.endDate.compareTo(a.endDate));
    if (cycles.length < 2) {
      continue;
    }
    // Prefer the cycle immediately older than the current one for that card.
    final currentIndex = cycles.indexWhere((cycle) => currentIds.contains(cycle.id));
    final previous = currentIndex >= 0 && currentIndex + 1 < cycles.length
        ? cycles[currentIndex + 1]
        : cycles.length > 1 && currentIds.contains(cycles.first.id)
            ? cycles[1]
            : null;
    if (previous == null) {
      continue;
    }
    previousIds.add(previous.id);
    previousPeriods.add((previous.endDate.year, previous.endDate.month));
  }

  final olderPeriods = <(int, int)>{};
  for (final cycle in allCycles) {
    final period = (cycle.endDate.year, cycle.endDate.month);
    if (currentPeriods.contains(period) || previousPeriods.contains(period)) {
      continue;
    }
    olderPeriods.add(period);
  }

  final sortedOlder = olderPeriods.toList()
    ..sort((a, b) {
      final byYear = b.$1.compareTo(a.$1);
      if (byYear != 0) {
        return byYear;
      }
      return b.$2.compareTo(a.$2);
    });

  return [
    const TransactionCycleFilterOption(
      filter: TransactionCycleFilter.current,
      label: 'Current cycle',
    ),
    const TransactionCycleFilterOption(
      filter: TransactionCycleFilter.previous,
      label: 'Last cycle',
    ),
    for (final period in sortedOlder)
      TransactionCycleFilterOption(
        filter: PeriodTransactionCycleFilter(year: period.$1, month: period.$2),
        label: formatCyclePeriodLabel(period.$1, period.$2),
      ),
  ];
}

/// Resolves billing-cycle IDs for the selected filter across active cards.
Set<int> resolveTransactionCycleIds({
  required TransactionCycleFilter filter,
  required List<BillingCycle> currentCycles,
  required List<BillingCycle> allCycles,
}) {
  switch (filter) {
    case CurrentTransactionCycleFilter():
      return currentCycles.map((cycle) => cycle.id).toSet();
    case PreviousTransactionCycleFilter():
      final currentIds = currentCycles.map((cycle) => cycle.id).toSet();
      final previousIds = <int>{};
      final byCard = <int, List<BillingCycle>>{};
      for (final cycle in allCycles) {
        byCard.putIfAbsent(cycle.creditCardId, () => []).add(cycle);
      }
      for (final cycles in byCard.values) {
        cycles.sort((a, b) => b.endDate.compareTo(a.endDate));
        final currentIndex =
            cycles.indexWhere((cycle) => currentIds.contains(cycle.id));
        if (currentIndex >= 0 && currentIndex + 1 < cycles.length) {
          previousIds.add(cycles[currentIndex + 1].id);
        } else if (cycles.length > 1 && currentIds.contains(cycles.first.id)) {
          previousIds.add(cycles[1].id);
        }
      }
      return previousIds;
    case PeriodTransactionCycleFilter(:final year, :final month):
      return allCycles
          .where(
            (cycle) =>
                cycle.endDate.year == year && cycle.endDate.month == month,
          )
          .map((cycle) => cycle.id)
          .toSet();
  }
}
