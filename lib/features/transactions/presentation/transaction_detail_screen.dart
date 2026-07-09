import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final cardTransactionProvider =
    FutureProvider.family<CardTransaction?, int>((ref, id) {
  return ref.watch(cardTransactionRepositoryProvider).getById(id);
});

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final int transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  final _personController = TextEditingController();
  bool _isRecoverable = false;

  @override
  void dispose() {
    _personController.dispose();
    super.dispose();
  }

  Future<void> _saveRecoverable(CardTransaction tx) async {
    await ref.read(recoverableRepositoryProvider).markRecoverable(
          transactionId: tx.id,
          isRecoverable: _isRecoverable,
          person: _isRecoverable ? _personController.text : null,
        );
    ref.invalidate(cardTransactionProvider(widget.transactionId));
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);
    ref.invalidate(recoverableSummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(cardTransactionProvider(widget.transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          if (_personController.text.isEmpty && tx.recoverablePerson != null) {
            _personController.text = tx.recoverablePerson!;
          }
          _isRecoverable = tx.isRecoverable;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                tx.merchant,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(formatPaise(tx.amountPaise)),
              Text('Source: ${tx.source}'),
              Text('Reviewed: ${tx.isReviewed ? 'Yes' : 'No'}'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Recoverable'),
                subtitle: const Text('Excluded from budgets'),
                value: _isRecoverable,
                onChanged: (value) => setState(() => _isRecoverable = value),
              ),
              if (_isRecoverable)
                TextField(
                  controller: _personController,
                  decoration: const InputDecoration(
                    labelText: 'Person',
                  ),
                ),
              if (_isRecoverable) ...[
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _saveRecoverable(tx),
                  child: const Text('Save recoverable'),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Original SMS',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(tx.rawSms ?? 'Not available'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
