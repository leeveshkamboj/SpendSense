import 'package:spendsense/features/bills/domain/bill_reminders.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';

class BillReminderService {
  BillReminderService({
    required BillReminderScheduler scheduler,
    required NotificationPermissionGateway permissionGateway,
  })  : _scheduler = scheduler,
        _permissionGateway = permissionGateway;

  final BillReminderScheduler _scheduler;
  final NotificationPermissionGateway _permissionGateway;

  Future<void> syncReminders({
    required List<BillSummary> bills,
    required DateTime asOf,
  }) async {
    await _scheduler.cancelAll();

    final permission = await _permissionGateway.check();
    if (permission != NotificationPermissionState.granted) {
      return;
    }

    final reminders = buildBillReminders(bills: bills, asOf: asOf);
    for (final reminder in reminders) {
      await _scheduler.schedule(reminder);
    }
  }
}
