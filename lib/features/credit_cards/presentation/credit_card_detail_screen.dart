import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/recoverables/presentation/recoverable_summary_card.dart';

final creditCardProvider = FutureProvider.family<CreditCard?, int>((ref, id) {
  return ref.watch(creditCardRepositoryProvider).getById(id);
});

final billingCyclesProvider = FutureProvider.family<List<BillingCycle>, int>((
  ref,
  cardId,
) {
  return ref.watch(creditCardRepositoryProvider).listCycles(cardId);
});

class CreditCardDetailScreen extends ConsumerWidget {
  const CreditCardDetailScreen({required this.cardId, super.key});

  final int cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(creditCardProvider(cardId));
    final cycles = ref.watch(billingCyclesProvider(cardId));

    return Scaffold(
      appBar: AppBar(title: const Text('Credit Card')),
      body: card.when(
        data: (creditCard) {
          if (creditCard == null) {
            return const Center(child: Text('Card not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                creditCard.nickname,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('${creditCard.bank} ••${creditCard.lastFourDigits}'),
              if (creditCard.billDayOfMonth == null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      context.push('/accounts/cards/$cardId/configure'),
                  child: const Text('Configure billing'),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Billing Cycles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              cycles.when(
                data: (billingCycles) {
                  if (billingCycles.isEmpty) {
                    return const Text('No billing cycles yet');
                  }

                  final now = DateTime.now();
                  return Column(
                    children: [
                      for (final cycle in billingCycles)
                        _CycleTile(
                          summary: summarizeBillingCycle(
                            cycle: cycle,
                            billAmountPaise: 0,
                            asOf: now,
                          ),
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
}

class _CycleTile extends StatelessWidget {
  const _CycleTile({required this.summary});

  final BillingCycleSummary summary;

  @override
  Widget build(BuildContext context) {
    final cycle = summary.cycle;
    final periodLabel =
        '${_formatDate(cycle.startDate)} – ${_formatDate(cycle.endDate)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(periodLabel),
              subtitle: Text(
                'Bill Amount: ${formatPaise(summary.billAmountPaise)}',
              ),
              trailing: Text(billingCycleStatusLabel(summary.status)),
            ),
            RecoverableSummaryCard(billingCycleId: cycle.id),
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
