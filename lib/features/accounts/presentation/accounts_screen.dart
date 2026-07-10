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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Credit Cards',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          creditCards.when(
            data: (cards) {
              if (cards.isEmpty) {
                return const _EmptyAccountsCard(
                  icon: Icons.credit_card_outlined,
                  message: 'No credit cards yet',
                );
              }

              return Column(
                children: [
                  for (final card in cards) _CreditCardTile(card: card),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Bank Accounts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          bankAccounts.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const _EmptyAccountsCard(
                  icon: Icons.account_balance_outlined,
                  message: 'No bank accounts yet',
                );
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

class _EmptyAccountsCard extends StatelessWidget {
  const _EmptyAccountsCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _CreditCardTile extends StatelessWidget {
  const _CreditCardTile({required this.card});

  final CreditCard card;

  @override
  Widget build(BuildContext context) {
    final needsBilling = card.billDayOfMonth == null;
    final color = Color(card.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.credit_card, color: color, size: 20),
        ),
        title: Text(card.nickname),
        subtitle: Text('${card.bank} ••${card.lastFourDigits}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (needsBilling)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  label: const Text('Set up billing'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          if (needsBilling) {
            context.push('/accounts/cards/${card.id}/configure');
            return;
          }
          context.push('/accounts/cards/${card.id}');
        },
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

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(account.nickname),
            subtitle: Text('${account.bank} ••${account.lastFourDigits}'),
            trailing: Text(
              formatPaise(balance),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      },
      loading: () => ListTile(title: Text(account.nickname)),
      error: (_, _) => ListTile(title: Text(account.nickname)),
    );
  }
}
