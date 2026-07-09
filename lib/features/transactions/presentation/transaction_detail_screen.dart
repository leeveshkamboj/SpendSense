import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

final cardTransactionProvider =
    FutureProvider.family<CardTransaction?, int>((ref, id) {
  return ref.watch(cardTransactionRepositoryProvider).getById(id);
});

final cardTransactionTagsProvider =
    FutureProvider.family<List<String>, int>((ref, id) {
  return ref.watch(tagRepositoryProvider).listForCardTransaction(id);
});

final cardTransactionReceiptsProvider =
    FutureProvider.family<List<String>, int>((ref, id) {
  return ref.watch(receiptRepositoryProvider).listForTransaction(id);
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
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _referenceController = TextEditingController();
  final _receiptPathController = TextEditingController();
  bool _isRecoverable = false;
  int? _loadedId;

  @override
  void dispose() {
    _personController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _referenceController.dispose();
    _receiptPathController.dispose();
    super.dispose();
  }

  void _loadFields(CardTransaction tx) {
    if (_loadedId == tx.id) return;
    _loadedId = tx.id;
    _personController.text = tx.recoverablePerson ?? '';
    _notesController.text = tx.notes ?? '';
    _locationController.text = tx.location ?? '';
    _referenceController.text = tx.referenceNumber ?? '';
    _isRecoverable = tx.isRecoverable;
  }

  Future<void> _saveRecoverable(CardTransaction tx) async {
    await ref.read(recoverableRepositoryProvider).markRecoverable(
          transactionId: tx.id,
          isRecoverable: _isRecoverable,
          person: _isRecoverable ? _personController.text : null,
        );
    _invalidateAll();
  }

  Future<void> _saveDetails(CardTransaction tx) async {
    await ref.read(cardTransactionRepositoryProvider).updateDetails(
          transactionId: tx.id,
          amountPaise: tx.amountPaise,
          merchant: tx.merchant,
          category: tx.category,
          transactionAt: tx.transactionAt,
          billingCycleId: tx.billingCycleId,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          referenceNumber: _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
        );
    _invalidateAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
    }
  }

  Future<void> _addReceipt() async {
    final path = _receiptPathController.text.trim();
    if (path.isEmpty) return;

    await ref.read(receiptRepositoryProvider).add(
          transactionId: widget.transactionId,
          filePath: path,
        );
    _receiptPathController.clear();
    ref.invalidate(cardTransactionReceiptsProvider(widget.transactionId));
  }

  void _invalidateAll() {
    ref.invalidate(cardTransactionProvider(widget.transactionId));
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);
    ref.invalidate(recoverableSummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(cardTransactionProvider(widget.transactionId));
    final tags = ref.watch(cardTransactionTagsProvider(widget.transactionId));
    final receipts =
        ref.watch(cardTransactionReceiptsProvider(widget.transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/transactions/${widget.transactionId}/edit'),
          ),
        ],
      ),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          _loadFields(tx);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                tx.merchant,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(formatPaise(tx.amountPaise)),
              Text('Kind: ${tx.kind}'),
              Text('Source: ${tx.source}'),
              Text('Category: ${tx.category ?? 'Miscellaneous'}'),
              tags.when(
                data: (tagNames) => tagNames.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Tags: ${tagNames.join(', ')}'),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference number',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
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
                  decoration: const InputDecoration(labelText: 'Person'),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _saveRecoverable(tx),
                child: const Text('Save recoverable'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _saveDetails(tx),
                child: const Text('Save details'),
              ),
              const SizedBox(height: 16),
              Text(
                'Receipts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              receipts.when(
                data: (paths) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final path in paths)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(path),
                      ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _receiptPathController,
                decoration: const InputDecoration(
                  labelText: 'Add receipt file path',
                ),
              ),
              TextButton(
                onPressed: _addReceipt,
                child: const Text('Add receipt'),
              ),
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
