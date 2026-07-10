import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/domain/bill_reminders.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';

void main() {
  group('Bill reminders', () {
    BillSummary bill({
      required BillingCycleStatus status,
      required DateTime dueDate,
    }) {
      return BillSummary(
        cycleId: 1,
        creditCardId: 1,
        cardNickname: 'HDFC ••5534',
        dueDate: dueDate,
        billAmountPaise: 50000,
        paymentsAppliedPaise: 0,
        totalOutstandingPaise: 50000,
        netOutstandingPaise: 50000,
        status: status,
      );
    }

    test('schedules reminders three days, one day, and on due date', () {
      final reminders = buildBillReminders(
        bills: [
          bill(
            status: BillingCycleStatus.billed,
            dueDate: DateTime(2026, 8, 5),
          ),
        ],
        asOf: DateTime(2026, 7, 1),
      );

      expect(reminders.map((r) => r.kind).toSet(), {
        BillReminderKind.threeDaysBefore,
        BillReminderKind.oneDayBefore,
        BillReminderKind.onDueDate,
      });
      expect(
        reminders
            .firstWhere((r) => r.kind == BillReminderKind.threeDaysBefore)
            .scheduledAt,
        DateTime(2026, 8, 2),
      );
    });

    test('skips reminders that are already in the past', () {
      final reminders = buildBillReminders(
        bills: [
          bill(
            status: BillingCycleStatus.partiallyPaid,
            dueDate: DateTime(2026, 8, 5),
          ),
        ],
        asOf: DateTime(2026, 8, 5),
      );

      expect(reminders.length, 1);
      expect(reminders.single.kind, BillReminderKind.onDueDate);
    });

    test('does not schedule reminders for paid bills', () {
      final reminders = buildBillReminders(
        bills: [
          bill(
            status: BillingCycleStatus.paid,
            dueDate: DateTime(2026, 8, 5),
          ),
        ],
        asOf: DateTime(2026, 7, 1),
      );

      expect(reminders, isEmpty);
    });
  });
}
