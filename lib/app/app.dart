import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/router.dart';
import 'package:spendsense/app/theme.dart';
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
        return CaptureNotificationListener(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
