import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/app.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/bills/data/bill_reminder_providers.dart';
import 'package:spendsense/features/bills/data/local_notifications_bill_reminder_scheduler.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final reminderScheduler =
      await LocalNotificationsBillReminderScheduler.create();

  runApp(
    ProviderScope(
      overrides: [
        billReminderSchedulerProvider.overrideWithValue(reminderScheduler),
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
    return const OnboardingGate(child: SpendSenseApp());
  }
}
