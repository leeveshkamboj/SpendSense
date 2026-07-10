import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/transaction_edit_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({required this.transactionId, super.key});

  final int transactionId;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _transactionAt;
  String? _category;
  int? _loadedTransactionId;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadFields(CardTransaction transaction) {
    if (_loadedTransactionId == transaction.id) {
      return;
    }

    _loadedTransactionId = transaction.id;
    _merchantController.text = transaction.merchant;
    _amountController.text = (transaction.amountPaise / 100).toStringAsFixed(2);
    _transactionAt = transaction.transactionAt;
    _category = transaction.category;
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _transactionAt == null) {
      return;
    }

    await ref.read(transactionEditRepositoryProvider).update(
          transactionId: widget.transactionId,
          amountPaise: (amount * 100).round(),
          merchant: _merchantController.text.trim(),
          category: _category,
          transactionAt: _transactionAt!,
        );

    ref.invalidate(cardTransactionProvider(widget.transactionId));
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(groupedCardTransactionsProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);
    invalidateDashboardAndWidgets(ref);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(cardTransactionProvider(widget.transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit transaction')),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          _loadFields(tx);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _merchantController,
                decoration: const InputDecoration(labelText: 'Merchant'),
              ),
              const SizedBox(height: 12),
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
              Text('Category: ${_category ?? 'Miscellaneous'}'),
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
                onPressed: _save,
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
