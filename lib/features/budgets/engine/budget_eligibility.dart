import 'package:spendsense/features/budgets/domain/budget_transaction.dart';

bool countsTowardBudget(BudgetTransaction transaction) {
  if (transaction.source != BudgetTransactionSource.creditCard) {
    return false;
  }

  if (transaction.kind != BudgetTransactionKind.expense) {
    return false;
  }

  return !transaction.isRecoverable;
}
