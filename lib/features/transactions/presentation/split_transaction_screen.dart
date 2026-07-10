import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class SplitTransactionScreen extends ConsumerStatefulWidget {
  const SplitTransactionScreen({required this.transactionId, super.key});

  final int transactionId;

  @override
  ConsumerState<SplitTransactionScreen> createState() =>
      _SplitTransactionScreenState();
}

class _SplitTransactionScreenState extends ConsumerState<SplitTransactionScreen> {
  final _personalController = TextEditingController();
  final _recoverableController = TextEditingController();
  final _personController = TextEditingController();

  @override
  void dispose() {
    _personalController.dispose();
    _recoverableController.dispose();
    _personController.dispose();
    super.dispose();
  }

  Future<void> _split(CardTransaction transaction) async {
    final personal = double.tryParse(_personalController.text);
    final recoverable = double.tryParse(_recoverableController.text);
    if (personal == null || recoverable == null) {
      return;
    }

    await ref.read(recoverableRepositoryProvider).splitTransaction(
          transactionId: transaction.id,
          personalAmountPaise: (personal * 100).round(),
          recoverableAmountPaise: (recoverable * 100).round(),
          person: _personController.text,
        );

    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);
    ref.invalidate(recoverableSummaryProvider);
    invalidateDashboardAndWidgets(ref);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(cardTransactionProvider(widget.transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Split transaction')),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(tx.merchant, style: Theme.of(context).textTheme.titleLarge),
              Text('Total: ${formatPaise(tx.amountPaise)}'),
              const SizedBox(height: 16),
              TextField(
                controller: _personalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Personal amount',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _recoverableController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Recoverable amount',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _personController,
                decoration: const InputDecoration(labelText: 'Person'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _split(tx),
                child: const Text('Split'),
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
