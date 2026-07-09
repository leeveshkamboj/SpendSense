import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_service.dart';
import 'package:spendsense/features/budgets/presentation/spending_alert_listener.dart';

final spendingAlertServiceProvider = Provider<SpendingAlertService>((ref) {
  return SpendingAlertService(
    budgets: ref.watch(budgetRepositoryProvider),
    permissionGateway: ref.watch(notificationPermissionGatewayProvider),
    onAlert: ({
      required threshold,
      required spentPaise,
      required limitPaise,
      required notificationsGranted,
    }) {
      ref.read(spendingAlertEventsProvider.notifier).state = AsyncData(
        SpendingAlertEvent(
          threshold: threshold,
          spentPaise: spentPaise,
          limitPaise: limitPaise,
          notificationsGranted: notificationsGranted,
        ),
      );
    },
  );
});

final spendingAlertEventsProvider =
    StateProvider<AsyncValue<SpendingAlertEvent?>>((ref) {
  return const AsyncData(null);
});

final spendingAlertSyncProvider = FutureProvider<void>((ref) async {
  await ref.watch(spendingAlertServiceProvider).syncAlerts(asOf: DateTime.now());
});
