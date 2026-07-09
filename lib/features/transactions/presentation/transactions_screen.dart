import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

enum TransactionSegment { cards, accounts }

final transactionSegmentProvider = StateProvider<TransactionSegment>(
  (ref) => TransactionSegment.cards,
);

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ref.watch(transactionSegmentProvider);
    final groups = ref.watch(groupedCardTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<TransactionSegment>(
              segments: const [
                ButtonSegment(
                  value: TransactionSegment.cards,
                  label: Text('Cards'),
                ),
                ButtonSegment(
                  value: TransactionSegment.accounts,
                  label: Text('Accounts'),
                ),
              ],
              selected: {segment},
              onSelectionChanged: (selection) {
                ref.read(transactionSegmentProvider.notifier).state =
                    selection.first;
              },
            ),
          ),
        ),
      ),
      body: segment == TransactionSegment.accounts
          ? _AccountsSegmentBody()
          : groups.when(
              data: (cycleGroups) {
                if (cycleGroups.isEmpty) {
                  return const Center(child: Text('No card transactions yet'));
                }

                return ListView.builder(
                  itemCount: cycleGroups.length,
                  itemBuilder: (context, index) {
                    final group = cycleGroups[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            group.cycleLabel,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        for (final transaction in group.transactions)
                          ListTile(
                            title: Text(transaction.merchant),
                            subtitle: Text(
                              formatPaise(transaction.amountPaise),
                            ),
                            trailing: transaction.isReviewed
                                ? null
                                : const Icon(Icons.fiber_new, size: 16),
                            onTap: () => context.push(
                              '/transactions/${transaction.id}',
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
    );
  }
}

class _AccountsSegmentBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupedBankTransactionsProvider);

    return groups.when(
      data: (monthGroups) {
        if (monthGroups.isEmpty) {
          return const Center(child: Text('No bank account transactions yet'));
        }

        return ListView.builder(
          itemCount: monthGroups.length,
          itemBuilder: (context, index) {
            final group = monthGroups[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    group.header,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final transaction in group.transactions)
                  ListTile(
                    title: Text(
                      transaction.beneficiary ??
                          transaction.merchant ??
                          transaction.category ??
                          'Transaction',
                    ),
                    subtitle: Text(formatPaise(transaction.amountPaise)),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
