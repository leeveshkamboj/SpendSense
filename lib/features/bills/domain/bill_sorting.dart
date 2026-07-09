import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';

List<BillSummary> sortBills(List<BillSummary> bills) {
  final sorted = List<BillSummary>.from(bills);
  sorted.sort((a, b) {
    final aOverdue = a.status == BillingCycleStatus.overdue;
    final bOverdue = b.status == BillingCycleStatus.overdue;
    if (aOverdue != bOverdue) {
      return aOverdue ? -1 : 1;
    }

    final aDue = a.dueDate ?? DateTime(9999);
    final bDue = b.dueDate ?? DateTime(9999);
    return aDue.compareTo(bDue);
  });
  return sorted;
}
