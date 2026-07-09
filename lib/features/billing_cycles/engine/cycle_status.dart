import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';

const _paidThresholdPaise = 100;

/// Whether the bill should be generated on [asOf] (bill date reached).
bool shouldGenerateBill({
  required DateTime cycleEndDate,
  required DateTime asOf,
}) {
  return !asOf.isBefore(
    DateTime(cycleEndDate.year, cycleEndDate.month, cycleEndDate.day),
  );
}

BillingCycleStatus determineCycleStatus({
  required bool billGenerated,
  required int billAmountPaise,
  required int paymentsAppliedPaise,
  required DateTime? dueDate,
  required DateTime asOf,
}) {
  if (!billGenerated) {
    return BillingCycleStatus.open;
  }

  final remaining = billAmountPaise - paymentsAppliedPaise;
  if (remaining <= _paidThresholdPaise) {
    return BillingCycleStatus.paid;
  }

  final isPastDue = dueDate != null &&
      asOf.isAfter(DateTime(dueDate.year, dueDate.month, dueDate.day));

  if (paymentsAppliedPaise > 0) {
    return isPastDue
        ? BillingCycleStatus.overdue
        : BillingCycleStatus.partiallyPaid;
  }

  return isPastDue ? BillingCycleStatus.overdue : BillingCycleStatus.billed;
}
