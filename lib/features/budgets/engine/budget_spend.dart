import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/engine/budget_eligibility.dart';

int calculatePersonalSpendPaise(Iterable<BudgetTransaction> transactions) {
  var total = 0;

  for (final transaction in transactions) {
    if (!countsTowardBudget(transaction)) {
      continue;
    }
    total += transaction.amountPaise;
  }

  return total;
}

Map<String, int> calculateCategorySpendPaise(
  Iterable<BudgetTransaction> transactions,
) {
  final totals = <String, int>{};

  for (final transaction in transactions) {
    if (!countsTowardBudget(transaction)) {
      continue;
    }

    final category = transaction.category ?? 'Miscellaneous';
    totals[category] = (totals[category] ?? 0) + transaction.amountPaise;
  }

  return totals;
}
