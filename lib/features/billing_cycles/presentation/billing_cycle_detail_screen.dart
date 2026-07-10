import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/analytics/engine/analytics_period.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/card_transaction_list_tile.dart';

final billingCycleDetailProvider =
    FutureProvider.family<BillingCycleDetail?, int>((ref, cycleId) async {
  final creditCards = ref.watch(creditCardRepositoryProvider);
  final transactions = ref.watch(cardTransactionRepositoryProvider);
  final cycle = await creditCards.findCycleById(cycleId);
  if (cycle == null) {
    return null;
  }

  final card = await creditCards.getById(cycle.creditCardId);
  final cycleTransactions = await transactions.listForBillingCycleInclusive(
    cardId: cycle.creditCardId,
    cycle: cycle,
  );
  final billAmountPaise = calculateBillAmount(
    cycleTransactions.map(cardTransactionLineFrom),
  );

  return BillingCycleDetail(
    cycle: cycle,
    card: card,
    billAmountPaise: billAmountPaise,
    transactions: cycleTransactions,
  );
});

class BillingCycleDetail {
  const BillingCycleDetail({
    required this.cycle,
    required this.card,
    required this.billAmountPaise,
    required this.transactions,
  });

  final BillingCycle cycle;
  final CreditCard? card;
  final int billAmountPaise;
  final List<CardTransaction> transactions;
}

class BillingCycleDetailScreen extends ConsumerWidget {
  const BillingCycleDetailScreen({
    required this.cardId,
    required this.cycleId,
    super.key,
  });

  final int cardId;
  final int cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(billingCycleDetailProvider(cycleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Billing cycle')),
      body: detail.when(
        data: (value) {
          if (value == null || value.card == null) {
            return const Center(child: Text('Billing cycle not found'));
          }

          final summary = summarizeBillingCycle(
            cycle: value.cycle,
            billAmountPaise: value.billAmountPaise,
            asOf: DateTime.now(),
          );
          final periodLabel = formatBillingCycleLabel(
            value.cycle.startDate,
            value.cycle.endDate,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.card!.nickname,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(periodLabel),
                      const SizedBox(height: 12),
                      Text(
                        formatPaise(value.billAmountPaise),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Net spend · ${billingCycleStatusLabel(summary.status)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (value.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No transactions in this cycle')),
                )
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var index = 0;
                          index < value.transactions.length;
                          index++) ...[
                        if (index > 0)
                          const Divider(height: 1, indent: 72, endIndent: 16),
                        CardTransactionListTile(
                          transaction: value.transactions[index],
                          cardNickname: value.card!.nickname,
                          colorValue: value.card!.colorValue,
                          cardNetwork: value.card!.network,
                        ),
                      ],
                    ],
                  ),
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
