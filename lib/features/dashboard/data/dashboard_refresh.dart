import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_providers.dart';

void invalidateDashboardAndWidgets(WidgetRef ref) {
  ref.invalidate(dashboardCardSpendProvider);
  ref.invalidate(dashboardRecentTransactionsProvider);
  ref.invalidate(homeWidgetSyncProvider);
}
