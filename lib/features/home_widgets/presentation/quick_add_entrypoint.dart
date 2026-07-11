import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/theme.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/home_widgets/presentation/widget_quick_add_sheet.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_service.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';

/// Entry for [QuickAddActivity] — compact sheet over the launcher.
///
/// Intentionally skips [AppLockGate]: home-screen quick-add is a short write
/// path that should work without unlocking the full app.
@pragma('vm:entry-point')
Future<void> quickAddMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final captureNotifications = await CaptureNotificationService.create();

  runApp(
    ProviderScope(
      overrides: [
        captureNotificationServiceProvider.overrideWithValue(
          captureNotifications,
        ),
      ],
      child: const _QuickAddBootstrap(),
    ),
  );
}

class _QuickAddBootstrap extends ConsumerWidget {
  const _QuickAddBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SpendSense',
      debugShowCheckedModeBanner: false,
      theme: spendSenseLightTheme(),
      darkTheme: spendSenseDarkTheme(),
      themeMode: _mapThemeMode(themeMode.valueOrNull ?? 'system'),
      home: const WidgetQuickAddSheet(),
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
