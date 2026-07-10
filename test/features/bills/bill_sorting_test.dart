import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/bills/domain/bill_sorting.dart';

void main() {
  group('Bill sorting', () {
    BillSummary bill({
      required int id,
      required BillingCycleStatus status,
      required DateTime dueDate,
    }) {
      return BillSummary(
        cycleId: id,
        creditCardId: 1,
        cardNickname: 'HDFC ••5534',
        cardNetwork: null,
        colorValue: 0xFF00695C,
        dueDate: dueDate,
        billAmountPaise: 10000,
        paymentsAppliedPaise: 0,
        totalOutstandingPaise: 10000,
        netOutstandingPaise: 10000,
        status: status,
      );
    }

    test('sorts overdue bills before upcoming bills', () {
      final sorted = sortBills([
        bill(
          id: 1,
          status: BillingCycleStatus.billed,
          dueDate: DateTime(2026, 7, 15),
        ),
        bill(
          id: 2,
          status: BillingCycleStatus.overdue,
          dueDate: DateTime(2026, 6, 1),
        ),
      ]);

      expect(sorted.map((row) => row.cycleId).toList(), [2, 1]);
    });

    test('sorts bills by nearest due date within each group', () {
      final sorted = sortBills([
        bill(
          id: 1,
          status: BillingCycleStatus.billed,
          dueDate: DateTime(2026, 8, 1),
        ),
        bill(
          id: 2,
          status: BillingCycleStatus.partiallyPaid,
          dueDate: DateTime(2026, 7, 10),
        ),
        bill(
          id: 3,
          status: BillingCycleStatus.overdue,
          dueDate: DateTime(2026, 5, 20),
        ),
        bill(
          id: 4,
          status: BillingCycleStatus.overdue,
          dueDate: DateTime(2026, 6, 5),
        ),
      ]);

      expect(sorted.map((row) => row.cycleId).toList(), [3, 4, 2, 1]);
    });
  });
}
