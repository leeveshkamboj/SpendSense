import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/analytics/engine/analytics_period.dart';

class TransactionCycleGroup {
  const TransactionCycleGroup({
    required this.cycleLabel,
    required this.cardNickname,
    required this.billingCycleId,
    required this.isCurrentCycle,
    required this.transactions,
  });

  final String cycleLabel;
  final String cardNickname;
  final int? billingCycleId;
  final bool isCurrentCycle;
  final List<CardTransaction> transactions;
}

List<TransactionCycleGroup> groupCardTransactionsByCycle({
  required List<CardTransaction> transactions,
  required Map<int, BillingCycle> cyclesById,
  required Map<int, String> nicknameByCardId,
  required Set<int> currentCycleIds,
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
    final cardNickname =
        nicknameByCardId[cycle.creditCardId] ?? 'Card ${cycle.creditCardId}';
    final label = formatBillingCycleLabel(cycle.startDate, cycle.endDate);
    final cycleTransactions = grouped[cycleId]!
      ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

    groups.add(
      TransactionCycleGroup(
        cycleLabel: label,
        cardNickname: cardNickname,
        billingCycleId: cycleId,
        isCurrentCycle: currentCycleIds.contains(cycleId),
        transactions: cycleTransactions,
      ),
    );
  }

  final unassigned = grouped.remove(null);
  if (unassigned != null && unassigned.isNotEmpty) {
    final byCardId = <int, List<CardTransaction>>{};
    for (final transaction in unassigned) {
      byCardId
          .putIfAbsent(transaction.creditCardId, () => [])
          .add(transaction);
    }

    final cardIds = byCardId.keys.toList()
      ..sort(
        (a, b) => (nicknameByCardId[a] ?? 'Card $a')
            .compareTo(nicknameByCardId[b] ?? 'Card $b'),
      );

    for (final cardId in cardIds) {
      final cardTransactions = byCardId[cardId]!
        ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));
      groups.add(
        TransactionCycleGroup(
          cycleLabel: 'Needs billing setup',
          cardNickname: nicknameByCardId[cardId] ?? 'Card $cardId',
          billingCycleId: null,
          isCurrentCycle: false,
          transactions: cardTransactions,
        ),
      );
    }
  }

  return groups;
}
