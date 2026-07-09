import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_status.dart';

void main() {
  group('Cycle status', () {
    test('stays open before bill date', () {
      final status = determineCycleStatus(
        billGenerated: false,
        billAmountPaise: 50000,
        paymentsAppliedPaise: 0,
        dueDate: DateTime(2026, 3, 5),
        asOf: DateTime(2026, 2, 10),
      );

      expect(status, BillingCycleStatus.open);
    });

    test('becomes billed automatically on bill date', () {
      final billGenerated = shouldGenerateBill(
        cycleEndDate: DateTime(2026, 2, 15),
        asOf: DateTime(2026, 2, 15),
      );

      expect(billGenerated, isTrue);

      final status = determineCycleStatus(
        billGenerated: true,
        billAmountPaise: 50000,
        paymentsAppliedPaise: 0,
        dueDate: DateTime(2026, 3, 5),
        asOf: DateTime(2026, 2, 15),
      );

      expect(status, BillingCycleStatus.billed);
    });

    test('marks paid when remaining balance is at most one rupee', () {
      final status = determineCycleStatus(
        billGenerated: true,
        billAmountPaise: 50000,
        paymentsAppliedPaise: 49950,
        dueDate: DateTime(2026, 3, 5),
        asOf: DateTime(2026, 2, 20),
      );

      expect(status, BillingCycleStatus.paid);
    });

    test('marks partially paid when some payment received', () {
      final status = determineCycleStatus(
        billGenerated: true,
        billAmountPaise: 50000,
        paymentsAppliedPaise: 20000,
        dueDate: DateTime(2026, 3, 5),
        asOf: DateTime(2026, 2, 20),
      );

      expect(status, BillingCycleStatus.partiallyPaid);
    });

    test('marks overdue when past due date with unpaid balance', () {
      final status = determineCycleStatus(
        billGenerated: true,
        billAmountPaise: 50000,
        paymentsAppliedPaise: 0,
        dueDate: DateTime(2026, 3, 5),
        asOf: DateTime(2026, 3, 6),
      );

      expect(status, BillingCycleStatus.overdue);
    });
  });
}
