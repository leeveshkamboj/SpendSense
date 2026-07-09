import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/router.dart';
import 'package:spendsense/app/theme.dart';
import 'package:spendsense/features/backup/presentation/data_recovery_gate.dart';
import 'package:spendsense/features/bills/data/bill_reminder_providers.dart';
import 'package:spendsense/features/app_lock/presentation/app_lock_gate.dart';
import 'package:spendsense/features/budgets/presentation/spending_alert_listener.dart';
import 'package:spendsense/features/home_widgets/presentation/home_widget_launch_listener.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';
import 'package:spendsense/features/sms_capture/presentation/capture_notification_listener.dart';

class SpendSenseApp extends ConsumerWidget {
  const SpendSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SpendSense',
      theme: spendSenseLightTheme(),
      darkTheme: spendSenseDarkTheme(),
      themeMode: _mapThemeMode(themeMode.valueOrNull ?? 'system'),
      routerConfig: router,
      builder: (context, child) {
        return AppHealthGate(
          child: OnboardingGate(
            child: AppLockGate(
              child: HomeWidgetLaunchListener(
                child: BillReminderSyncListener(
                  child: SpendingAlertListener(
                    child: CaptureNotificationListener(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ThemeMode _mapThemeMode(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
