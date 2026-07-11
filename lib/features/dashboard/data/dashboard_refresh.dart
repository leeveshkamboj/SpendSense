import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';

void invalidateDashboardAndWidgets(WidgetRef ref) {
  ref.invalidate(dashboardCardSpendProvider);
  ref.invalidate(dashboardRecentTransactionsProvider);
  ref.invalidate(monthlyBudgetProgressProvider);
  ref.invalidate(unpaidBillsProvider);
  ref.invalidate(spendingAlertSyncProvider);
  ref.invalidate(recoverableSummaryProvider);
  ref.invalidate(homeWidgetSyncProvider);
}
