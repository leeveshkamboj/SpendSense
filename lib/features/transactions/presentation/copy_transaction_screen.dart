import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/transaction_copy_providers.dart';
import 'package:spendsense/features/transactions/domain/card_transaction_copy_draft.dart';

final copyDraftProvider =
    FutureProvider.family<CardTransactionCopyDraft, int>((ref, transactionId) {
  return ref.watch(transactionCopyRepositoryProvider).draftFrom(transactionId);
});

class CopyTransactionScreen extends ConsumerStatefulWidget {
  const CopyTransactionScreen({required this.sourceTransactionId, super.key});

  final int sourceTransactionId;

  @override
  ConsumerState<CopyTransactionScreen> createState() =>
      _CopyTransactionScreenState();
}

class _CopyTransactionScreenState extends ConsumerState<CopyTransactionScreen> {
  final _amountController = TextEditingController();
  DateTime? _transactionAt;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save(CardTransactionCopyDraft draft) async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _transactionAt == null) {
      return;
    }

    await ref.read(transactionCopyRepositoryProvider).saveCopy(
          draft: draft,
          amountPaise: (amount * 100).round(),
          transactionAt: _transactionAt!,
        );

    ref.invalidate(cardTransactionsProvider);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(copyDraftProvider(widget.sourceTransactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Copy transaction')),
      body: draft.when(
        data: (value) {
          if (_amountController.text.isEmpty) {
            _amountController.text = '';
          }
          _transactionAt ??= DateTime.now();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(value.merchant, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Category: ${value.category ?? 'Miscellaneous'}'),
              if (value.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Tags: ${value.tags.join(', ')}'),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(_formatDate(_transactionAt!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDate: _transactionAt,
                  );
                  if (picked != null) {
                    setState(() {
                      _transactionAt = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        _transactionAt!.hour,
                        _transactionAt!.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(value),
                child: const Text('Save'),
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
