import 'package:spendsense/core/database/database.dart';

class TransactionCycleGroup {
  const TransactionCycleGroup({
    required this.cycleLabel,
    required this.transactions,
  });

  final String cycleLabel;
  final List<CardTransaction> transactions;
}

List<TransactionCycleGroup> groupCardTransactionsByCycle({
  required List<CardTransaction> transactions,
  required Map<int, BillingCycle> cyclesById,
}) {
  final grouped = <int?, List<CardTransaction>>{};

  for (final transaction in transactions) {
    grouped
        .putIfAbsent(transaction.billingCycleId, () => [])
        .add(transaction);
  }

  final cycleIds = grouped.keys.whereType<int>().toList()
    ..sort((a, b) => cyclesById[b]!.endDate.compareTo(cyclesById[a]!.endDate));

  final groups = <TransactionCycleGroup>[];

  for (final cycleId in cycleIds) {
    final cycle = cyclesById[cycleId]!;
    final label =
        '${_formatDate(cycle.startDate)} – ${_formatDate(cycle.endDate)}';
    final cycleTransactions = grouped[cycleId]!
      ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

    groups.add(
      TransactionCycleGroup(
        cycleLabel: label,
        transactions: cycleTransactions,
      ),
    );
  }

  final unassigned = grouped[null];
  if (unassigned != null && unassigned.isNotEmpty) {
    unassigned.sort((a, b) => b.transactionAt.compareTo(a.transactionAt));
    groups.add(
      TransactionCycleGroup(
        cycleLabel: 'Unassigned',
        transactions: unassigned,
      ),
    );
  }

  return groups;
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
