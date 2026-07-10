import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/analytics/engine/analytics_period.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_providers.dart';
import 'package:spendsense/features/credit_cards/domain/card_network.dart';
import 'package:spendsense/features/credit_cards/presentation/card_network_icon.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_avatar.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_limit_display.dart';
import 'package:spendsense/features/recoverables/presentation/recoverable_summary_card.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final creditCardProvider = FutureProvider.family<CreditCard?, int>((ref, id) {
  return ref.watch(creditCardRepositoryProvider).getById(id);
});

final billingCyclesProvider = FutureProvider.family<List<BillingCycle>, int>((
  ref,
  cardId,
) {
  return ref.watch(creditCardRepositoryProvider).listCycles(cardId);
});

final billingCycleSummariesProvider =
    FutureProvider.family<List<BillingCycleSummary>, int>((ref, cardId) async {
  final creditCards = ref.watch(creditCardRepositoryProvider);
  final transactions = ref.watch(cardTransactionRepositoryProvider);
  final cycles = await creditCards.listCycles(cardId);
  final now = DateTime.now();

  final summaries = <BillingCycleSummary>[];
  for (final cycle in cycles) {
    final cycleTransactions =
        await transactions.listForBillingCycleInclusive(
      cardId: cardId,
      cycle: cycle,
    );
    final billAmountPaise = calculateBillAmount(
      cycleTransactions.map(cardTransactionLineFrom),
    );
    summaries.add(
      summarizeBillingCycle(
        cycle: cycle,
        billAmountPaise: billAmountPaise,
        asOf: now,
      ),
    );
  }

  summaries.sort(
    (a, b) => b.cycle.endDate.compareTo(a.cycle.endDate),
  );

  return summaries;
});

final currentCycleIdsForCardProvider =
    FutureProvider.family<Set<int>, int>((ref, cardId) async {
  final cycles = await ref.watch(creditCardRepositoryProvider).listCurrentCycles();
  return cycles
      .where((cycle) => cycle.creditCardId == cardId)
      .map((cycle) => cycle.id)
      .toSet();
});

class CreditCardDetailScreen extends ConsumerWidget {
  const CreditCardDetailScreen({required this.cardId, super.key});

  final int cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(creditCardProvider(cardId));
    final poolId = card.valueOrNull?.creditLimitPoolId;
    final poolAsync = poolId == null
        ? null
        : ref.watch(creditLimitPoolProvider(poolId));
    final summaries = ref.watch(billingCycleSummariesProvider(cardId));
    final currentCycleIds = ref.watch(currentCycleIdsForCardProvider(cardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'archive', child: Text('Archive card')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete permanently'),
              ),
            ],
          ),
        ],
      ),
      body: card.when(
        data: (creditCard) {
          if (creditCard == null) {
            return const Center(child: Text('Card not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CreditCardAvatar(
                            network: creditCard.network,
                            colorValue: creditCard.colorValue,
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  creditCard.nickname,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  '${creditCard.bank} ••${creditCard.lastFourDigits}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (creditCard.network != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CardNetworkIcon.optional(
                              network: creditCard.network,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              CardNetwork.parse(creditCard.network)?.displayName ??
                                  creditCard.network!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      _CreditLimitLabel(
                        card: creditCard,
                        poolAsync: poolAsync,
                      ),
                      if (creditCard.billDayOfMonth != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Bill date: day ${creditCard.billDayOfMonth}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (creditCard.dueDateOffsetDays != null)
                          Text(
                            'Due date: ${creditCard.dueDateOffsetDays} days after bill',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/accounts/cards/$cardId/configure'),
                icon: const Icon(Icons.tune_outlined),
                label: const Text('Card settings'),
              ),
              const SizedBox(height: 24),
              Text(
                'Billing Cycles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              summaries.when(
                data: (rows) {
                  if (rows.isEmpty) {
                    return const Text('No billing cycles yet');
                  }

                  final currentIds =
                      currentCycleIds.valueOrNull ?? const <int>{};

                  return Column(
                    children: [
                      for (final summary in rows)
                        _CycleTile(
                          cardId: cardId,
                          summary: summary,
                          isCurrent: currentIds.contains(summary.cycle.id),
                        ),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final repository = ref.read(creditCardRepositoryProvider);
    if (value == 'archive') {
      await repository.archive(cardId);
      if (context.mounted) {
        context.pop();
      }
      return;
    }

    if (value == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete card permanently?'),
          content: const Text(
            'This removes the card and all associated transactions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
      await repository.deletePermanently(cardId);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}

class _CycleTile extends StatelessWidget {
  const _CycleTile({
    required this.cardId,
    required this.summary,
    required this.isCurrent,
  });

  final int cardId;
  final BillingCycleSummary summary;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final cycle = summary.cycle;
    final periodLabel = formatBillingCycleLabel(
      cycle.startDate,
      cycle.endDate,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push(
          '/accounts/cards/$cardId/cycles/${cycle.id}',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          periodLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Spend ${formatPaise(summary.billAmountPaise)} · '
                          '${billingCycleStatusLabel(summary.status)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Chip(
                      label: const Text('Current'),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (isCurrent) ...[
                const SizedBox(height: 8),
                RecoverableSummaryCard(billingCycleId: cycle.id),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditLimitLabel extends StatelessWidget {
  const _CreditLimitLabel({
    required this.card,
    required this.poolAsync,
  });

  final CreditCard card;
  final AsyncValue<CreditLimitPool?>? poolAsync;

  @override
  Widget build(BuildContext context) {
    if (poolAsync == null) {
      return Text(
        formatCreditCardLimitLabel(card: card),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: creditCardNeedsLimitSetup(card)
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
      );
    }

    return poolAsync!.when(
      data: (sharedPool) => Text(
        formatCreditCardLimitLabel(card: card, pool: sharedPool),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: creditCardNeedsLimitSetup(card)
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
      ),
      loading: () => Text(
        formatCreditCardLimitLabel(card: card),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      error: (_, __) => Text(
        formatCreditCardLimitLabel(card: card),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
