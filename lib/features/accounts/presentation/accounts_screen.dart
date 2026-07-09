import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/accounts/domain/account_balance.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';

final creditCardsProvider = FutureProvider<List<CreditCard>>((ref) {
  return ref.watch(creditCardRepositoryProvider).listActive();
});

final bankAccountsProvider = FutureProvider<List<BankAccount>>((ref) {
  return ref.watch(bankAccountRepositoryProvider).listActive();
});

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditCards = ref.watch(creditCardsProvider);
    final bankAccounts = ref.watch(bankAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Credit Cards',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          creditCards.when(
            data: (cards) {
              if (cards.isEmpty) {
                return const Text('No credit cards yet');
              }

              return Column(
                children: [
                  for (final card in cards)
                    ListTile(
                      title: Text(card.nickname),
                      subtitle: Text('${card.bank} ••${card.lastFourDigits}'),
                      trailing: card.billDayOfMonth == null
                          ? const Text('Setup required')
                          : null,
                      onTap: () => context.push('/accounts/cards/${card.id}'),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Bank Accounts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          bankAccounts.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const Text('No bank accounts yet');
              }

              return Column(
                children: [
                  for (final account in accounts)
                    _BankAccountTile(account: account),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/cards/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add card'),
      ),
    );
  }
}

class _BankAccountTile extends ConsumerWidget {
  const _BankAccountTile({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(bankAccountTransactionsProvider);

    return transactions.when(
      data: (allTransactions) {
        final accountTransactions = allTransactions
            .where((tx) => tx.bankAccountId == account.id)
            .toList();
        final balance = computeAccountBalance(
          openingBalancePaise: account.openingBalancePaise,
          transactions: accountTransactions,
        );

        return ListTile(
          title: Text(account.nickname),
          subtitle: Text('${account.bank} ••${account.lastFourDigits}'),
          trailing: Text(formatPaise(balance)),
        );
      },
      loading: () => ListTile(title: Text(account.nickname)),
      error: (_, _) => ListTile(title: Text(account.nickname)),
    );
  }
}
