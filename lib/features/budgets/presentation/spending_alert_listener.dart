import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/budgets/engine/budget_alerts.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';

class SpendingAlertListener extends ConsumerWidget {
  const SpendingAlertListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(spendingAlertEventsProvider, (previous, next) {
      final event = next.valueOrNull;
      if (event == null || event.notificationsGranted) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Budget alert: ${formatThreshold(event.threshold)} spent '
            '(${formatPaise(event.spentPaise)} of ${formatPaise(event.limitPaise)})',
          ),
        ),
      );
    });

    return child;
  }

  String formatThreshold(BudgetAlertThreshold threshold) {
    return switch (threshold) {
      BudgetAlertThreshold.seventyFivePercent => '75%',
      BudgetAlertThreshold.ninetyPercent => '90%',
      BudgetAlertThreshold.oneHundredPercent => '100%',
    };
  }
}

class SpendingAlertEvent {
  const SpendingAlertEvent({
    required this.threshold,
    required this.spentPaise,
    required this.limitPaise,
    required this.notificationsGranted,
  });

  final BudgetAlertThreshold threshold;
  final int spentPaise;
  final int limitPaise;
  final bool notificationsGranted;
}
