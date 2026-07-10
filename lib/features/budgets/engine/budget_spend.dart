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

Map<int, int> calculateCardSpendPaise(Iterable<BudgetTransaction> transactions) {
  final totals = <int, int>{};

  for (final transaction in transactions) {
    if (!countsTowardBudget(transaction)) {
      continue;
    }

    final cardId = transaction.cardId;
    if (cardId == null) {
      continue;
    }

    totals[cardId] = (totals[cardId] ?? 0) + transaction.amountPaise;
  }

  return totals;
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
