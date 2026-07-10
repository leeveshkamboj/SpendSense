import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_status.dart';

export 'package:spendsense/core/formatting/amount_display.dart' show formatPaise;

class BillingCycleSummary {
  const BillingCycleSummary({
    required this.cycle,
    required this.billAmountPaise,
    required this.status,
  });

  final BillingCycle cycle;
  final int billAmountPaise;
  final BillingCycleStatus status;
}

BillingCycleSummary summarizeBillingCycle({
  required BillingCycle cycle,
  required int billAmountPaise,
  required DateTime asOf,
}) {
  return BillingCycleSummary(
    cycle: cycle,
    billAmountPaise: billAmountPaise,
    status: determineCycleStatus(
      billGenerated: cycle.billGenerated,
      billAmountPaise: billAmountPaise,
      paymentsAppliedPaise: cycle.paymentsAppliedPaise,
      dueDate: cycle.dueDate,
      asOf: asOf,
    ),
  );
}

String billingCycleStatusLabel(BillingCycleStatus status) {
  return switch (status) {
    BillingCycleStatus.open => 'Open',
    BillingCycleStatus.billed => 'Billed',
    BillingCycleStatus.partiallyPaid => 'Partially Paid',
    BillingCycleStatus.paid => 'Paid',
    BillingCycleStatus.overdue => 'Overdue',
  };
}

