import 'package:spendsense/features/budgets/domain/budget_transaction.dart';

BudgetTransactionKind budgetTransactionKindFromString(String kind) {
  switch (kind) {
    case 'expense':
      return BudgetTransactionKind.expense;
    case 'refund':
    case 'cashback':
      return BudgetTransactionKind.refund;
    case 'card_payment':
      return BudgetTransactionKind.cardPayment;
    default:
      for (final value in BudgetTransactionKind.values) {
        if (value.name == kind) {
          return value;
        }
      }
      return BudgetTransactionKind.expense;
  }
}
