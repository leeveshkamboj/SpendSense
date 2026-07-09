import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_service.dart';

final spendingAlertServiceProvider = Provider<SpendingAlertService>((ref) {
  return SpendingAlertService(
    budgets: ref.watch(budgetRepositoryProvider),
    permissionGateway: ref.watch(notificationPermissionGatewayProvider),
  );
});

final spendingAlertSyncProvider = FutureProvider<void>((ref) async {
  await ref.watch(spendingAlertServiceProvider).syncAlerts(asOf: DateTime.now());
});
