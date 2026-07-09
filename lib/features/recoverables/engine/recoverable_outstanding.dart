import 'package:spendsense/features/recoverables/domain/recoverable_expense.dart';
import 'package:spendsense/features/recoverables/domain/recovery_link.dart';

int unsettledRecoverablePaise({
  required RecoverableExpense expense,
  required Iterable<RecoveryAllocation> recoveries,
}) {
  final recovered = recoveries
      .where((link) => link.recoverableTransactionId == expense.transactionId)
      .fold<int>(0, (sum, link) => sum + link.amountPaise);

  return expense.amountPaise - recovered;
}

Map<String, int> summarizeRecoverablesByPerson({
  required Iterable<RecoverableExpense> expenses,
  required Iterable<RecoveryAllocation> recoveries,
}) {
  final totals = <String, int>{};

  for (final expense in expenses) {
    final unsettled = unsettledRecoverablePaise(
      expense: expense,
      recoveries: recoveries,
    );
    if (unsettled <= 0) {
      continue;
    }

    totals[expense.person] = (totals[expense.person] ?? 0) + unsettled;
  }

  return totals;
}

int totalUnsettledRecoverablePaise({
  required Iterable<RecoverableExpense> expenses,
  required Iterable<RecoveryAllocation> recoveries,
}) {
  return expenses.fold<int>(0, (sum, expense) {
    return sum +
        unsettledRecoverablePaise(expense: expense, recoveries: recoveries);
  });
}
