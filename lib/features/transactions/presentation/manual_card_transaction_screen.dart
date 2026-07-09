import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class ManualCardTransactionScreen extends ConsumerStatefulWidget {
  const ManualCardTransactionScreen({super.key});

  @override
  ConsumerState<ManualCardTransactionScreen> createState() =>
      _ManualCardTransactionScreenState();
}

class _ManualCardTransactionScreenState
    extends ConsumerState<ManualCardTransactionScreen> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  String _kind = 'expense';
  String _adjustmentDirection = 'charge';
  int? _selectedCardId;
  DateTime _transactionAt = DateTime.now();

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cardId = _selectedCardId;
    final amount = double.tryParse(_amountController.text);
    if (cardId == null || amount == null) {
      return;
    }

    final creditCards = ref.read(creditCardRepositoryProvider);
    final billingCycleId = await creditCards.findBillingCycleIdForTransaction(
      cardId: cardId,
      transactionAt: _transactionAt,
    );

    final kind = _kind == 'adjustment'
        ? (_adjustmentDirection == 'charge' ? 'expense' : 'refund')
        : _kind;

    await ref.read(cardTransactionRepositoryProvider).insert(
          NewCardTransaction(
            creditCardId: cardId,
            billingCycleId: billingCycleId,
            kind: kind,
            amountPaise: (amount * 100).round(),
            merchant: _merchantController.text.trim().isEmpty
                ? _defaultMerchantForKind()
                : _merchantController.text.trim(),
            transactionAt: _transactionAt,
            source: 'Manual',
            category: _defaultCategoryForKind(),
          ),
        );

    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);

    if (mounted) {
      context.pop();
    }
  }

  String _defaultMerchantForKind() {
    return switch (_kind) {
      'cashback' => 'Cashback',
      'adjustment' =>
        _adjustmentDirection == 'charge' ? 'Adjustment (charge)' : 'Adjustment (credit)',
      'refund' => 'Refund',
      _ => 'Expense',
    };
  }

  String? _defaultCategoryForKind() {
    return switch (_kind) {
      'cashback' => 'Miscellaneous',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(activeCreditCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add transaction')),
      body: cards.when(
        data: (cardList) {
          if (cardList.isEmpty) {
            return const Center(child: Text('Add a credit card first'));
          }

          _selectedCardId ??= cardList.first.id;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedCardId,
                decoration: const InputDecoration(labelText: 'Card'),
                items: [
                  for (final card in cardList)
                    DropdownMenuItem(
                      value: card.id,
                      child: Text(card.nickname),
                    ),
                ],
                onChanged: (value) => setState(() => _selectedCardId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'refund', child: Text('Refund')),
                  DropdownMenuItem(value: 'cashback', child: Text('Cashback')),
                  DropdownMenuItem(
                    value: 'adjustment',
                    child: Text('Adjustment'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _kind = value);
                },
              ),
              if (_kind == 'adjustment') ...[
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'charge', label: Text('Charge')),
                    ButtonSegment(value: 'credit', label: Text('Credit')),
                  ],
                  selected: {_adjustmentDirection},
                  onSelectionChanged: (selection) {
                    setState(() => _adjustmentDirection = selection.first);
                  },
                ),
              ],
              const SizedBox(height: 12),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(_formatDate(_transactionAt)),
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
