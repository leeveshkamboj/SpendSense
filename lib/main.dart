import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/app.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/bills/data/bill_reminder_providers.dart';
import 'package:spendsense/features/bills/data/local_notifications_bill_reminder_scheduler.dart';
import 'package:spendsense/features/home_widgets/presentation/quick_add_entrypoint.dart'
    as quick_add;
import 'package:spendsense/features/sms_capture/background/sms_background_handler.dart'
    as sms_bg;
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

/// Root-library fallback if native code uses the 2-arg DartEntrypoint.
/// Prefer the package library URI in [SmsBackgroundEngine].
@pragma('vm:entry-point')
void smsBackgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  sms_bg.SmsBackgroundHandler.install();
}

/// Root-library fallback for [QuickAddActivity] when the package URI entry fails.
@pragma('vm:entry-point')
Future<void> quickAddMain() => quick_add.quickAddMain();

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseProvider);
    return const SpendSenseApp();
  }
}
