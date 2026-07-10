import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/formatting/transaction_amount_display.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/accounts/domain/account_balance.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/transactions/domain/grouped_bank_transactions.dart';

final bankAccountProvider = FutureProvider.family<BankAccount?, int>((ref, id) {
  return ref.watch(bankAccountRepositoryProvider).getById(id);
});

class BankAccountDetailScreen extends ConsumerWidget {
  const BankAccountDetailScreen({required this.accountId, super.key});

  final int accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(bankAccountProvider(accountId));
    final transactions = ref.watch(bankAccountTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bank account')),
      body: account.when(
        data: (row) {
          if (row == null) {
            return const Center(child: Text('Account not found'));
          }

          return transactions.when(
            data: (allTransactions) {
              final accountTransactions = allTransactions
                  .where((tx) => tx.bankAccountId == accountId)
                  .toList();
              final balance = computeAccountBalance(
                openingBalancePaise: row.openingBalancePaise,
                transactions: accountTransactions,
              );
              final groups = groupBankTransactionsByMonth(
                transactions: accountTransactions,
                now: DateTime.now(),
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.nickname,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${row.bank} ••${row.lastFourDigits}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            formatPaise(balance),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Current balance',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (groups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    )
                  else
                    for (final group in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        child: Text(
                          group.header,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < group.transactions.length;
                                index++) ...[
                              if (index > 0)
                                const Divider(height: 1, indent: 16, endIndent: 16),
                              _BankTransactionRow(
                                transaction: group.transactions[index],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _BankTransactionRow extends StatelessWidget {
  const _BankTransactionRow({required this.transaction});

  final BankAccountTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final direction = bankTransactionDirection(transaction.kind);
    final amountColor = transactionDirectionColor(scheme, direction);
    final title = transaction.beneficiary ??
        transaction.merchant ??
        transaction.category ??
        'Transaction';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
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
          ),
          Text(
            formatSignedPaise(transaction.amountPaise, direction),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
          ),
        ],
      ),
    );
  }
}
