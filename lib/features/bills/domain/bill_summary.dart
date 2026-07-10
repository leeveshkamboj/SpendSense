import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';

class BillSummary {
  const BillSummary({
    required this.cycleId,
    required this.creditCardId,
    required this.cardNickname,
    required this.dueDate,
    required this.billAmountPaise,
    required this.paymentsAppliedPaise,
    required this.totalOutstandingPaise,
    required this.netOutstandingPaise,
    required this.status,
  });

  final int cycleId;
  final int creditCardId;
  final String cardNickname;
  final DateTime? dueDate;
  final int billAmountPaise;
  final int paymentsAppliedPaise;
  final int totalOutstandingPaise;
  final int netOutstandingPaise;
  final BillingCycleStatus status;
}
