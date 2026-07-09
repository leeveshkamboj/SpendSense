import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final cardTransactionProvider =
    FutureProvider.family<CardTransaction?, int>((ref, id) {
  return ref.watch(cardTransactionRepositoryProvider).getById(id);
});

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(cardTransactionProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

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
