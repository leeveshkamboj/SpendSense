import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/transactions/domain/transaction_cycle_filter.dart';
import 'package:spendsense/features/transactions/domain/transaction_filters.dart';

BillingCycle _cycle({
  required int id,
  required DateTime start,
  required DateTime end,
}) {
  return BillingCycle(
    id: id,
    creditCardId: 1,
    startDate: start,
    endDate: end,
    billGenerated: true,
    paymentsAppliedPaise: 0,
  );
}

void main() {
  group('TransactionCycleFilter options', () {
    test('lists current, last, then older bill months', () {
      final current = _cycle(
        id: 3,
        start: DateTime(2026, 6, 5),
        end: DateTime(2026, 7, 4),
      );
      final previous = _cycle(
        id: 2,
        start: DateTime(2026, 5, 5),
        end: DateTime(2026, 6, 4),
      );
      final older = _cycle(
        id: 1,
        start: DateTime(2026, 4, 5),
        end: DateTime(2026, 5, 4),
      );

      final options = buildTransactionCycleFilterOptions(
        currentCycles: [current],
        allCycles: [current, previous, older],
      );

      expect(options.map((option) => option.label).toList(), [
        'Current cycle',
        'Last cycle',
        'May 2026 cycle',
      ]);
    });
  });

  group('resolveTransactionCycleIds', () {
    test('resolves previous and period cycle ids', () {
      final current = _cycle(
        id: 3,
        start: DateTime(2026, 6, 5),
        end: DateTime(2026, 7, 4),
      );
      final previous = _cycle(
        id: 2,
        start: DateTime(2026, 5, 5),
        end: DateTime(2026, 6, 4),
      );
      final older = _cycle(
        id: 1,
        start: DateTime(2026, 4, 5),
        end: DateTime(2026, 5, 4),
      );

      expect(
        resolveTransactionCycleIds(
          filter: TransactionCycleFilter.previous,
          currentCycles: [current],
          allCycles: [current, previous, older],
        ),
        {2},
      );
      expect(
        resolveTransactionCycleIds(
          filter: const PeriodTransactionCycleFilter(year: 2026, month: 5),
          currentCycles: [current],
          allCycles: [current, previous, older],
        ),
        {1},
      );
    });
  });

  group('TransactionFilters cycle defaults', () {
    test('current cycle does not count as an active filter', () {
      const filters = TransactionFilters();
      expect(filters.isEmpty, isTrue);
      expect(filters.activeCount, 0);
      expect(filters.isCurrentCycle, isTrue);
    });

    test('previous cycle counts as an active filter', () {
      const filters = TransactionFilters(
        cycleFilter: TransactionCycleFilter.previous,
      );
      expect(filters.isEmpty, isFalse);
      expect(filters.activeCount, 1);
      expect(filters.hasNonCycleFilters, isFalse);
    });
  });
}
