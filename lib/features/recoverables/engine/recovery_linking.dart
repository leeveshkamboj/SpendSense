import 'package:spendsense/features/recoverables/domain/recoverable_expense.dart';
import 'package:spendsense/features/recoverables/domain/recovery_link.dart';
import 'package:spendsense/features/recoverables/engine/recoverable_outstanding.dart';

bool validateRecoveryLink({
  required RecoverableExpense expense,
  required Iterable<RecoveryAllocation> existingRecoveries,
  required int newLinkAmountPaise,
}) {
  if (newLinkAmountPaise <= 0) {
    throw ArgumentError('Recovery amount must be positive');
  }

  final unsettled = unsettledRecoverablePaise(
    expense: expense,
    recoveries: existingRecoveries,
  );

  if (newLinkAmountPaise > unsettled) {
    throw ArgumentError('Recovery amount exceeds unsettled recoverable balance');
  }

  return true;
}
