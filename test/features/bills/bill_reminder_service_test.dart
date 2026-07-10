import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/data/bill_reminder_service.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';

void main() {
  group('BillReminderService', () {
    test('schedules reminders when notification permission is granted', () async {
      final scheduler = InMemoryBillReminderScheduler();
      final service = BillReminderService(
        scheduler: scheduler,
        permissionGateway: InMemoryNotificationPermissionGateway(
          NotificationPermissionState.granted,
        ),
      );

      await service.syncReminders(
        bills: [
          BillSummary(
            cycleId: 1,
            creditCardId: 1,
            cardNickname: 'HDFC ••5534',
            cardNetwork: null,
            colorValue: 0xFF00695C,
            dueDate: DateTime(2026, 8, 5),
            billAmountPaise: 50000,
            paymentsAppliedPaise: 0,
            totalOutstandingPaise: 50000,
            netOutstandingPaise: 50000,
            status: BillingCycleStatus.billed,
          ),
        ],
        asOf: DateTime(2026, 7, 1),
      );

      expect(scheduler.scheduled.length, 3);
    });

    test('skips scheduling when notification permission is denied', () async {
      final scheduler = InMemoryBillReminderScheduler();
      final service = BillReminderService(
        scheduler: scheduler,
        permissionGateway: InMemoryNotificationPermissionGateway(
          NotificationPermissionState.denied,
        ),
      );

      await service.syncReminders(
        bills: [
          BillSummary(
            cycleId: 1,
            creditCardId: 1,
            cardNickname: 'HDFC ••5534',
            cardNetwork: null,
            colorValue: 0xFF00695C,
            dueDate: DateTime(2026, 8, 5),
            billAmountPaise: 50000,
            paymentsAppliedPaise: 0,
            totalOutstandingPaise: 50000,
            netOutstandingPaise: 50000,
            status: BillingCycleStatus.billed,
          ),
        ],
        asOf: DateTime(2026, 7, 1),
      );

      expect(scheduler.scheduled, isEmpty);
    });
  });
}
