import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/credit_cards/presentation/card_network_icon.dart';
import 'package:spendsense/features/analytics/data/analytics_providers.dart';
import 'package:spendsense/features/analytics/domain/analytics_snapshot.dart';
import 'package:spendsense/features/analytics/engine/analytics_period.dart';
import 'package:spendsense/features/analytics/presentation/analytics_chart.dart';
import 'package:spendsense/features/analytics/presentation/analytics_chart_type.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/shell/spend_sense_app_bar_actions.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsBreakdown _breakdown = AnalyticsBreakdown.category;
  AnalyticsChartType _chartType = AnalyticsChartType.pie;
  int? _selectedCardId;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(analyticsSnapshotProvider);
    final cards = ref.watch(activeCreditCardsForAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBrandTitle(title: 'Analytics'),
        actions: spendSenseAppBarActions(context),
      ),
      body: snapshot.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Current: ${formatAnalyticsPeriodLabel(data.currentPeriodStart)}'
              ' vs Previous: ${formatAnalyticsPeriodLabel(data.previousPeriodStart)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final breakdown in AnalyticsBreakdown.values)
                  ChoiceChip(
                    label: Text(breakdown.label),
                    selected: _breakdown == breakdown,
                    onSelected: (_) => setState(() => _breakdown = breakdown),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chartType in AnalyticsChartType.values)
                  ChoiceChip(
                    label: Text(chartType.label),
                    selected: _chartType == chartType,
                    onSelected: (_) => setState(() => _chartType = chartType),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnalyticsChart(
              chartType: _chartType,
              currentTotals: _currentTotals(data),
              previousTotals: _previousTotals(data),
            ),
            const SizedBox(height: 24),
            Text(
              'Billing Cycle Comparison',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            cards.when(
              data: (cardList) {
                if (cardList.isEmpty) {
                  return const Text('Add a credit card to compare cycles');
                }

                _selectedCardId ??= cardList.first.id;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCardId,
                      decoration: const InputDecoration(labelText: 'Card'),
                      items: [
                        for (final card in cardList)
                          DropdownMenuItem(
                            value: card.id,
                            child: Row(
                              children: [
                                CardNetworkIcon.optional(
                                  network: card.network,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(card.nickname),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedCardId = value),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedCardId != null)
                      _BillingCycleComparisonCard(cardId: _selectedCardId!),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Map<String, int> _currentTotals(AnalyticsSnapshot data) {
    return switch (_breakdown) {
      AnalyticsBreakdown.category => data.currentCategoryTotals,
      AnalyticsBreakdown.merchant => data.currentMerchantTotals,
      AnalyticsBreakdown.card => data.currentCardTotals,
      AnalyticsBreakdown.tag => data.currentTagTotals,
    };
  }

  Map<String, int> _previousTotals(AnalyticsSnapshot data) {
    return switch (_breakdown) {
      AnalyticsBreakdown.category => data.previousCategoryTotals,
      AnalyticsBreakdown.merchant => data.previousMerchantTotals,
      AnalyticsBreakdown.card => data.previousCardTotals,
      AnalyticsBreakdown.tag => data.previousTagTotals,
    };
  }
}

class _BillingCycleComparisonCard extends ConsumerWidget {
  const _BillingCycleComparisonCard({required this.cardId});

  final int cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(billingCycleComparisonProvider(cardId));

    return comparison.when(
      data: (row) {
        if (row == null) {
          return const Text('No previous billing cycle to compare');
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.cardNickname, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _CycleSpendRow(
                  label: row.currentCycleLabel,
                  amountPaise: row.currentSpendPaise,
                ),
                const SizedBox(height: 4),
                _CycleSpendRow(
                  label: row.previousCycleLabel,
                  amountPaise: row.previousSpendPaise,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}

class _CycleSpendRow extends StatelessWidget {
  const _CycleSpendRow({
    required this.label,
    required this.amountPaise,
  });

  final String label;
  final int amountPaise;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        Text(formatPaise(amountPaise)),
      ],
    );
  }
}
