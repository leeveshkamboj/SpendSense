import 'package:spendsense/features/analytics/domain/analytics_transaction.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';

bool countsTowardCategoryOrMerchantAnalytics(AnalyticsTransaction transaction) {
  if (transaction.source != BudgetTransactionSource.creditCard) {
    return false;
  }
  if (transaction.kind != BudgetTransactionKind.expense) {
    return false;
  }
  return !transaction.isRecoverable;
}

bool countsTowardCardOrTagAnalytics(AnalyticsTransaction transaction) {
  return transaction.source == BudgetTransactionSource.creditCard &&
      transaction.kind == BudgetTransactionKind.expense;
}
