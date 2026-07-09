import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_recent_transaction.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/recoverables/presentation/recoverable_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _upcomingBillLimit = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(spendingAlertSyncProvider);
    final spend = ref.watch(dashboardCardSpendProvider);
    final budget = ref.watch(monthlyBudgetProgressProvider);
    final bills = ref.watch(unpaidBillsProvider);
    final recent = ref.watch(dashboardRecentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Card Spend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          spend.when(
            data: (summary) => _CardSpendCard(summary: summary),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
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
            'Upcoming Bills',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          bills.when(
            data: (rows) => _BillsSummaryCard(
              bills: rows.take(_upcomingBillLimit).toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          recent.when(
            data: (rows) => _RecentTransactionsCard(transactions: rows),
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

class _CardSpendCard extends StatelessWidget {
  const _CardSpendCard({required this.summary});

  final DashboardSpendSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.cards.isEmpty) {
      return const Text('No card spend this budget period');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatPaise(summary.totalPaise)} across ${summary.cards.length} cards',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            for (final card in summary.cards)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(card.nickname),
                    Text(formatPaise(card.spentPaise)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BillsSummaryCard extends StatelessWidget {
  const _BillsSummaryCard({required this.bills});

  final List<BillSummary> bills;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const Text('No upcoming bills');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final bill in bills)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bill.cardNickname),
                          Text(
                            bill.dueDate == null
                                ? 'Due date not set'
                                : 'Due ${_formatDate(bill.dueDate!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatPaise(bill.totalOutstandingPaise)),
                        Text(
                          'Net ${formatPaise(bill.netOutstandingPaise)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({required this.transactions});

  final List<DashboardRecentTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Text('No recent transactions');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final transaction in transactions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(transaction.merchant)),
                    Text(formatPaise(transaction.amountPaise)),
                  ],
                ),
              ),
          ],
        ),
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
