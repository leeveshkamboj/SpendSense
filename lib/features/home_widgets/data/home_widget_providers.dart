import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_repository.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_sync_service.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_writer.dart';
import 'package:spendsense/features/home_widgets/data/platform_home_widget_writer.dart';

final homeWidgetWriterProvider = Provider<HomeWidgetWriter>(
  (ref) => PlatformHomeWidgetWriter(),
);

final homeWidgetRepositoryProvider = Provider<HomeWidgetRepository>((ref) {
  return HomeWidgetRepository(
    dashboard: ref.watch(dashboardRepositoryProvider),
    budgets: ref.watch(budgetRepositoryProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
    creditLimitPools: ref.watch(creditLimitPoolRepositoryProvider),
    bills: ref.watch(billsRepositoryProvider),
  );
});

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return HomeWidgetSyncService(writer: ref.watch(homeWidgetWriterProvider));
});

final homeWidgetSyncProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(homeWidgetRepositoryProvider);
  final sync = ref.watch(homeWidgetSyncServiceProvider);
  final asOf = DateTime.now();
  final quickSummary = await repository.quickSummary(asOf: asOf);
  await sync.publishQuickSummary(quickSummary);
  final creditUtilization = await repository.creditUtilization(asOf: asOf);
  await sync.publishCreditUtilization(creditUtilization);
  final recentTransactions = await repository.recentTransactions();
  await sync.publishRecentTransactions(recentTransactions);
  final bills = await repository.upcomingBills(asOf: asOf);
  await sync.publishBills(bills);
  final budget = await repository.budgetProgress(asOf: asOf);
  await sync.publishBudget(budget);
});
