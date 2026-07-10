import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/formatting/merchant_display.dart';
import 'package:spendsense/core/formatting/transaction_amount_display.dart';
import 'package:spendsense/core/formatting/transaction_date_display.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_recent_transaction.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/recoverables/presentation/recoverable_summary_card.dart';
import 'package:spendsense/features/shell/spend_sense_app_bar_actions.dart';

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
      appBar: AppBar(
        title: const AppBrandTitle(title: 'Dashboard'),
        actions: spendSenseAppBarActions(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          spend.when(
            data: (summary) => _CardSpendSection(summary: summary),
            loading: () => const _DashboardSection(
              title: 'Card Spend',
              subtitle: 'All cards · current cycle or this month',
              child: _SectionCard(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            error: (error, _) => _DashboardSection(
              title: 'Card Spend',
              subtitle: 'All cards · current cycle or this month',
              child: _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          budget.when(
            data: (progress) => _BudgetSection(progress: progress),
            loading: () => const _DashboardSection(
              title: 'Monthly Budget',
              child: _SectionCard(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            error: (error, _) => _DashboardSection(
              title: 'Monthly Budget',
              child: _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          bills.when(
            data: (rows) => _BillsSection(
              bills: rows.take(_upcomingBillLimit).toList(),
            ),
            loading: () => const _DashboardSection(
              title: 'Upcoming Bills',
              child: _SectionCard(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            error: (error, _) => _DashboardSection(
              title: 'Upcoming Bills',
              child: _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          recent.when(
            data: (rows) => _RecentTransactionsSection(transactions: rows),
            loading: () => const _DashboardSection(
              title: 'Recent Transactions',
              child: _SectionCard(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            error: (error, _) => _DashboardSection(
              title: 'Recent Transactions',
              child: _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _DashboardSection(
            title: 'Recoverables',
            child: _SectionCard(
              child: RecoverableSummaryCard(embedded: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.5,
              ),
        ),
      ),
      child: child,
    );
  }
}

class _EmptySectionBody extends StatelessWidget {
  const _EmptySectionBody({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSpendSection extends StatelessWidget {
  const _CardSpendSection({required this.summary});

  final DashboardSpendSummary summary;

  @override
  Widget build(BuildContext context) {
    return _DashboardSection(
      title: 'Card Spend',
      subtitle: 'All cards · current cycle or this month',
      child: _SectionCard(
        child: summary.cards.isEmpty
            ? const _EmptySectionBody(
                icon: Icons.credit_card_outlined,
                message: 'No credit cards yet. Add one in Accounts.',
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatPaise(summary.totalPaise),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    Text(
                      'Across ${summary.cards.length} card${summary.cards.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    for (final card in summary.cards)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(card.nickname)),
                            Text(
                              formatPaise(card.spentPaise),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({required this.progress});

  final BudgetProgressSnapshot? progress;

  @override
  Widget build(BuildContext context) {
    return _DashboardSection(
      title: 'Monthly Budget',
      child: _SectionCard(
        child: progress == null
            ? const _EmptySectionBody(
                icon: Icons.savings_outlined,
                message: 'Set a monthly budget in Settings',
              )
            : _BudgetProgressBody(progress: progress!),
      ),
    );
  }
}

class _BillsSection extends StatelessWidget {
  const _BillsSection({required this.bills});

  final List<BillSummary> bills;

  @override
  Widget build(BuildContext context) {
    return _DashboardSection(
      title: 'Upcoming Bills',
      actionLabel: bills.isEmpty ? null : 'View all',
      onAction: bills.isEmpty ? null : () => context.go('/bills'),
      child: _SectionCard(
        child: bills.isEmpty
            ? const _EmptySectionBody(
                icon: Icons.request_page_outlined,
                message: 'No upcoming bills',
              )
            : _BillsSummaryBody(bills: bills),
      ),
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({required this.transactions});

  final List<DashboardRecentTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return _DashboardSection(
      title: 'Recent Transactions',
      actionLabel: transactions.isEmpty ? null : 'View all',
      onAction: transactions.isEmpty ? null : () => context.go('/transactions'),
      child: _SectionCard(
        child: transactions.isEmpty
            ? const _EmptySectionBody(
                icon: Icons.receipt_long_outlined,
                message: 'No transactions yet',
              )
            : _RecentTransactionsBody(transactions: transactions),
      ),
    );
  }
}

class _BillsSummaryBody extends StatelessWidget {
  const _BillsSummaryBody({required this.bills});

  final List<BillSummary> bills;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < bills.length; index++) ...[
          if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bills[index].cardNickname,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bills[index].dueDate == null
                            ? 'Due date not set'
                            : 'Due ${_formatDate(bills[index].dueDate!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatPaise(bills[index].totalOutstandingPaise),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Net ${formatPaise(bills[index].netOutstandingPaise)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _RecentTransactionsBody extends StatelessWidget {
  const _RecentTransactionsBody({required this.transactions});

  final List<DashboardRecentTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < transactions.length; index++) ...[
          if (index > 0) const Divider(height: 1, indent: 72, endIndent: 16),
          _TransactionRow(transaction: transactions[index]),
        ],
      ],
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  const _TransactionRow({required this.transaction});

  final DashboardRecentTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayNames = ref.watch(merchantDisplayNamesProvider).valueOrNull;
    final label = resolveMerchantDisplayLabel(
      transaction.merchant,
      customDisplayName: displayNames?[transaction.merchant],
    );
    final color = Color(transaction.colorValue);
    final scheme = Theme.of(context).colorScheme;
    final direction = cardTransactionDirection(transaction.kind);
    final amountColor = transactionDirectionColor(scheme, direction);

    return InkWell(
      onTap: () => context.go('/transactions'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                merchantInitial(label),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.cardNickname} · '
                    '${formatTransactionSubtitle(transaction.transactionAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatSignedPaise(transaction.amountPaise, direction),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                      ),
                ),
                Text(
                  transactionDirectionLabel(direction),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgressBody extends StatelessWidget {
  const _BudgetProgressBody({required this.progress});

  final BudgetProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final usedFraction = progress.usedFraction.clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    final barColor = usedFraction >= 1
        ? scheme.error
        : usedFraction >= 0.85
            ? scheme.tertiary
            : scheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  formatPaise(progress.spentPaise),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                'of ${formatPaise(progress.limitPaise)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${formatPaise(progress.remainingPaise)} remaining · '
            'projected ${formatPaise(progress.projectedPaise)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usedFraction,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}
