import 'package:spendsense/features/linking/domain/expense_candidate.dart';

int? findRefundExpenseMatch({
  required int cardId,
  required String merchant,
  required int amountPaise,
  required List<ExpenseCandidate> expenses,
}) {
  for (final expense in expenses.reversed) {
    if (expense.cardId != cardId) continue;
    if (expense.merchant != merchant) continue;
    if (expense.amountPaise != amountPaise) continue;
    return expense.transactionId;
  }

  return null;
}

int? billingCycleForRefund({
  required int? matchedExpenseTransactionId,
  required List<ExpenseCandidate> expenses,
}) {
  if (matchedExpenseTransactionId == null) return null;

  for (final expense in expenses) {
    if (expense.transactionId == matchedExpenseTransactionId) {
      return expense.billingCycleId;
    }
  }

  return null;
}
