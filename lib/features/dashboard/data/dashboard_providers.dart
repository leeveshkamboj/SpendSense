import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_repository.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_recent_transaction.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
  );
});

final dashboardCardSpendProvider = FutureProvider<DashboardSpendSummary>((ref) {
  return ref
      .watch(dashboardRepositoryProvider)
      .cardSpendSummary(asOf: DateTime.now());
});

final dashboardRecentTransactionsProvider =
    FutureProvider<List<DashboardRecentTransaction>>((ref) {
  return ref.watch(dashboardRepositoryProvider).recentTransactions();
});
