import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';

class ArchiveSettingsScreen extends ConsumerWidget {
  const ArchiveSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(archivedCreditCardsProvider);
    final accounts = ref.watch(archivedBankAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Credit cards', style: Theme.of(context).textTheme.titleMedium),
          cards.when(
            data: (rows) {
              if (rows.isEmpty) {
                return const ListTile(title: Text('No archived cards'));
              }
              return Column(
                children: [
                  for (final card in rows)
                    ListTile(
                      title: Text(card.nickname),
                      subtitle: Text('${card.bank} ••${card.lastFourDigits}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          final repository =
                              ref.read(creditCardRepositoryProvider);
                          if (value == 'restore') {
                            await repository.unarchive(card.id);
                          } else if (value == 'delete') {
                            final confirmed = await _confirmDelete(context);
                            if (confirmed) {
                              await repository.deletePermanently(card.id);
                            }
                          }
                          ref.invalidate(archivedCreditCardsProvider);
                          ref.invalidate(creditCardsProvider);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'restore', child: Text('Restore')),
                          PopupMenuItem(value: 'delete', child: Text('Delete permanently')),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => ListTile(title: Text('Error: $error')),
          ),
          const SizedBox(height: 24),
          Text('Bank accounts', style: Theme.of(context).textTheme.titleMedium),
          accounts.when(
            data: (rows) {
              if (rows.isEmpty) {
                return const ListTile(title: Text('No archived accounts'));
              }
              return Column(
                children: [
                  for (final account in rows)
                    ListTile(
                      title: Text(account.nickname),
                      subtitle:
                          Text('${account.bank} ••${account.lastFourDigits}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          final repository =
                              ref.read(bankAccountRepositoryProvider);
                          if (value == 'restore') {
                            await repository.unarchive(account.id);
                          } else if (value == 'delete') {
                            final confirmed = await _confirmDelete(context);
                            if (confirmed) {
                              await repository.deletePermanently(account.id);
                            }
                          }
                          ref.invalidate(archivedBankAccountsProvider);
                          ref.invalidate(bankAccountsProvider);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'restore', child: Text('Restore')),
                          PopupMenuItem(value: 'delete', child: Text('Delete permanently')),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => ListTile(title: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This removes the card or account and all associated transactions.',
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
    return result ?? false;
  }
}

final archivedCreditCardsProvider = FutureProvider((ref) {
  return ref.watch(creditCardRepositoryProvider).listArchived();
});

final archivedBankAccountsProvider = FutureProvider((ref) {
  return ref.watch(bankAccountRepositoryProvider).listArchived();
});
