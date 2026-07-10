import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/app.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/bills/data/bill_reminder_providers.dart';
import 'package:spendsense/features/bills/data/local_notifications_bill_reminder_scheduler.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_service.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final reminderScheduler =
      await LocalNotificationsBillReminderScheduler.create();
  final captureNotifications = await CaptureNotificationService.create();

  runApp(
    ProviderScope(
      overrides: [
        billReminderSchedulerProvider.overrideWithValue(reminderScheduler),
        captureNotificationServiceProvider.overrideWithValue(
          captureNotifications,
        ),
      ],
      child: const _AppBootstrap(),
    ),
  );
}

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseProvider);
    return const SpendSenseApp();
  }
}
