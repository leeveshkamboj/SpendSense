import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/budgets/engine/budget_alerts.dart';

typedef SpendingAlertHandler = void Function({
  required BudgetAlertThreshold threshold,
  required int spentPaise,
  required int limitPaise,
  required bool notificationsGranted,
});

class SpendingAlertService {
  SpendingAlertService({
    required BudgetRepository budgets,
    required NotificationPermissionGateway permissionGateway,
    this.onAlert,
  })  : _budgets = budgets,
        _permissionGateway = permissionGateway;

  final BudgetRepository _budgets;
  final NotificationPermissionGateway _permissionGateway;
  final SpendingAlertHandler? onAlert;

  Future<void> syncAlerts({required DateTime asOf}) async {
    final permission = await _permissionGateway.check();
    final notificationsGranted =
        permission == NotificationPermissionState.granted;

    final progress = await _budgets.monthlyProgress(asOf: asOf);
    if (progress == null) {
      return;
    }

    final crossed = await _budgets.crossedMonthlyAlertThresholds(asOf: asOf);
    if (crossed.isEmpty) {
      return;
    }

    for (final threshold in crossed) {
      onAlert?.call(
        threshold: threshold,
        spentPaise: progress.spentPaise,
        limitPaise: progress.limitPaise,
        notificationsGranted: notificationsGranted,
      );
    }

    await _budgets.recordCrossedThresholds(
      periodStart: progress.periodStart,
      thresholds: crossed,
    );
  }
}
