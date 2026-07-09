import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/analytics/data/analytics_repository.dart';
import 'package:spendsense/features/analytics/domain/analytics_snapshot.dart';
import 'package:spendsense/features/analytics/domain/billing_cycle_comparison.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(
    budgets: ref.watch(budgetRepositoryProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
  );
});

final analyticsSnapshotProvider = FutureProvider<AnalyticsSnapshot>((ref) {
  return ref.watch(analyticsRepositoryProvider).snapshot(asOf: DateTime.now());
});

final billingCycleComparisonProvider =
    FutureProvider.family<BillingCycleComparison?, int>((ref, cardId) {
  return ref
      .watch(analyticsRepositoryProvider)
      .billingCycleComparison(creditCardId: cardId, asOf: DateTime.now());
});

final activeCreditCardsForAnalyticsProvider = FutureProvider((ref) {
  return ref.watch(creditCardRepositoryProvider).listActive();
});
