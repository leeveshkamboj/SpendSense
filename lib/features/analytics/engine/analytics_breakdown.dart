import 'package:spendsense/features/analytics/domain/analytics_transaction.dart';
import 'package:spendsense/features/analytics/engine/analytics_eligibility.dart';

Map<String, int> calculateCategoryAnalytics(
  Iterable<AnalyticsTransaction> transactions,
) {
  final totals = <String, int>{};

  for (final transaction in transactions) {
    if (!countsTowardCategoryOrMerchantAnalytics(transaction)) {
      continue;
    }

    final category = transaction.category ?? 'Miscellaneous';
    totals[category] = (totals[category] ?? 0) + transaction.amountPaise;
  }

  return totals;
}

Map<String, int> calculateMerchantAnalytics(
  Iterable<AnalyticsTransaction> transactions,
) {
  final totals = <String, int>{};

  for (final transaction in transactions) {
    if (!countsTowardCategoryOrMerchantAnalytics(transaction)) {
      continue;
    }

    totals[transaction.merchant] =
        (totals[transaction.merchant] ?? 0) + transaction.amountPaise;
  }

  return totals;
}

Map<String, int> calculateCardAnalytics(
  Iterable<AnalyticsTransaction> transactions,
) {
  final totals = <String, int>{};

  for (final transaction in transactions) {
    if (!countsTowardCardOrTagAnalytics(transaction)) {
      continue;
    }

    final label = transaction.cardNickname ?? 'Card ${transaction.cardId}';
    totals[label] = (totals[label] ?? 0) + transaction.amountPaise;
  }

  return totals;
}

Map<String, int> calculateTagAnalytics(
  Iterable<AnalyticsTransaction> transactions,
) {
  final totals = <String, int>{};

  for (final transaction in transactions) {
    if (!countsTowardCardOrTagAnalytics(transaction)) {
      continue;
    }

    if (transaction.tags.isEmpty) {
      continue;
    }

    for (final tag in transaction.tags) {
      totals[tag] = (totals[tag] ?? 0) + transaction.amountPaise;
    }
  }

  return totals;
}

int calculateExpenseSpendPaise(Iterable<AnalyticsTransaction> transactions) {
  var total = 0;
  for (final transaction in transactions) {
    if (!countsTowardCardOrTagAnalytics(transaction)) {
      continue;
    }
    total += transaction.amountPaise;
  }
  return total;
}
