import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class CycleMoveScreen extends ConsumerStatefulWidget {
  const CycleMoveScreen({required this.transactionId, super.key});

  final int transactionId;

  @override
  ConsumerState<CycleMoveScreen> createState() => _CycleMoveScreenState();
}

class _CycleMoveScreenState extends ConsumerState<CycleMoveScreen> {
  int? _selectedCycleId;

  Future<void> _move() async {
    final cycleId = _selectedCycleId;
    if (cycleId == null) {
      return;
    }

    await ref.read(transactionCycleMoveRepositoryProvider).moveToCycle(
          transactionId: widget.transactionId,
          targetCycleId: cycleId,
        );

    ref.invalidate(cardTransactionProvider(widget.transactionId));
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
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
      appBar: AppBar(title: const Text('Cycle move')),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          final cyclesAsync = ref.watch(
            creditCardCyclesProvider(tx.creditCardId),
          );

          return cyclesAsync.when(
            data: (cycles) {
              _selectedCycleId ??= tx.billingCycleId ?? cycles.first.id;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    tx.merchant,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCycleId,
                    decoration: const InputDecoration(
                      labelText: 'Billing cycle',
                    ),
                    items: [
                      for (final cycle in cycles)
                        DropdownMenuItem(
                          value: cycle.id,
                          child: Text(
                            '${_formatDate(cycle.startDate)} – ${_formatDate(cycle.endDate)}',
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCycleId = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _move,
                    child: const Text('Move'),
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

final creditCardCyclesProvider =
    FutureProvider.family<List<BillingCycle>, int>((ref, cardId) {
  return ref.watch(creditCardRepositoryProvider).listCycles(cardId);
});

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
