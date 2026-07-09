import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class MergeTransactionScreen extends ConsumerStatefulWidget {
  const MergeTransactionScreen({required this.survivorTransactionId, super.key});

  final int survivorTransactionId;

  @override
  ConsumerState<MergeTransactionScreen> createState() =>
      _MergeTransactionScreenState();
}

class _MergeTransactionScreenState extends ConsumerState<MergeTransactionScreen> {
  int? _duplicateId;

  Future<void> _merge(CardTransaction survivor) async {
    final duplicateId = _duplicateId;
    if (duplicateId == null) {
      return;
    }

    await ref.read(transactionMergeRepositoryProvider).merge(
          survivorTransactionId: survivor.id,
          duplicateTransactionId: duplicateId,
        );

    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final survivor =
        ref.watch(cardTransactionProvider(widget.survivorTransactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Merge transaction')),
      body: survivor.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          final candidatesAsync = ref.watch(
            mergeCandidatesProvider('${tx.creditCardId}_${tx.id}'),
          );

          return candidatesAsync.when(
            data: (candidates) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Keep: ${tx.merchant} (${formatPaise(tx.amountPaise)})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Merge with duplicate',
                    ),
                    initialValue: _duplicateId,
                    items: [
                      for (final candidate in candidates)
                        DropdownMenuItem(
                          value: candidate.id,
                          child: Text(
                            '${candidate.merchant} ${formatPaise(candidate.amountPaise)}',
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _duplicateId = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _duplicateId == null ? null : () => _merge(tx),
                    child: const Text('Merge'),
                  ),
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

final mergeCandidatesProvider =
    FutureProvider.family<List<CardTransaction>, String>((ref, key) async {
  final parts = key.split('_');
  final cardId = int.parse(parts[0]);
  final excludeId = int.parse(parts[1]);
  final all =
      await ref.watch(cardTransactionRepositoryProvider).listForCard(cardId);
  return all.where((tx) => tx.id != excludeId).toList();
});
