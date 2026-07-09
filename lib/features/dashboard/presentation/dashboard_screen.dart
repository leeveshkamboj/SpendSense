import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/recoverables/presentation/recoverable_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(spendingAlertSyncProvider);
    final budget = ref.watch(monthlyBudgetProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monthly Budget',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          budget.when(
            data: (progress) {
              if (progress == null) {
                return const Text('Set a monthly budget in Settings');
              }

              return _BudgetProgressCard(progress: progress);
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Recoverables',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const RecoverableSummaryCard(),
        ],
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({required this.progress});

  final BudgetProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final usedFraction = progress.usedFraction.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatPaise(progress.spentPaise)} used of ${formatPaise(progress.limitPaise)}',
            ),
            const SizedBox(height: 4),
            Text('${formatPaise(progress.remainingPaise)} remaining'),
            const SizedBox(height: 4),
            Text(
              'Projected ${formatPaise(progress.projectedPaise)} by period end',
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: usedFraction),
          ],
        ),
      ),
    );
  }
}
