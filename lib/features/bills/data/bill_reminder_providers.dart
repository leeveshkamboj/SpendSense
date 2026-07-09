import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/data/bill_reminder_service.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';

final billReminderSchedulerProvider = Provider<BillReminderScheduler>((ref) {
  return InMemoryBillReminderScheduler();
});

final billReminderServiceProvider = Provider<BillReminderService>((ref) {
  return BillReminderService(
    scheduler: ref.watch(billReminderSchedulerProvider),
    permissionGateway: ref.watch(notificationPermissionGatewayProvider),
  );
});

class BillReminderSyncListener extends ConsumerWidget {
  const BillReminderSyncListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(unpaidBillsProvider, (previous, next) {
      next.whenData((bills) async {
        await ref.read(billReminderServiceProvider).syncReminders(
              bills: bills,
              asOf: DateTime.now(),
            );
      });
    });

    return child;
  }
}
