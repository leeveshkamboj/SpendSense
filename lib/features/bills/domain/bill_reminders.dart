import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';

enum BillReminderKind {
  threeDaysBefore,
  oneDayBefore,
  onDueDate,
}

class BillReminder {
  const BillReminder({
    required this.cycleId,
    required this.cardNickname,
    required this.netOutstandingPaise,
    required this.scheduledAt,
    required this.kind,
  });

  final int cycleId;
  final String cardNickname;
  final int netOutstandingPaise;
  final DateTime scheduledAt;
  final BillReminderKind kind;
}

List<BillReminder> buildBillReminders({
  required List<BillSummary> bills,
  required DateTime asOf,
}) {
  final reminders = <BillReminder>[];
  final asOfDate = DateTime(asOf.year, asOf.month, asOf.day);

  for (final bill in bills) {
    if (bill.status == BillingCycleStatus.paid || bill.dueDate == null) {
      continue;
    }

    final dueDate = DateTime(
      bill.dueDate!.year,
      bill.dueDate!.month,
      bill.dueDate!.day,
    );

    final schedule = {
      BillReminderKind.threeDaysBefore: dueDate.subtract(const Duration(days: 3)),
      BillReminderKind.oneDayBefore: dueDate.subtract(const Duration(days: 1)),
      BillReminderKind.onDueDate: dueDate,
    };

    for (final entry in schedule.entries) {
      if (entry.value.isBefore(asOfDate)) {
        continue;
      }

      reminders.add(
        BillReminder(
          cycleId: bill.cycleId,
          cardNickname: bill.cardNickname,
          netOutstandingPaise: bill.netOutstandingPaise,
          scheduledAt: entry.value,
          kind: entry.key,
        ),
      );
    }
  }

  return reminders;
}
