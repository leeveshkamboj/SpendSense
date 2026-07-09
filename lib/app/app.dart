import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/router.dart';
import 'package:spendsense/app/theme.dart';
import 'package:spendsense/features/bills/data/bill_reminder_providers.dart';
import 'package:spendsense/features/sms_capture/presentation/capture_notification_listener.dart';

class SpendSenseApp extends ConsumerWidget {
  const SpendSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SpendSense',
      theme: spendSenseLightTheme(),
      darkTheme: spendSenseDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return BillReminderSyncListener(
          child: CaptureNotificationListener(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
