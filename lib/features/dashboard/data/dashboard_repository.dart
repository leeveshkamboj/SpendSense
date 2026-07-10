import 'package:spendsense/features/billing_cycles/engine/cycle_spend.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_recent_transaction.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class DashboardRepository {
  DashboardRepository({
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
  })  : _creditCards = creditCards,
        _cardTransactions = cardTransactions;

  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;

  Future<DashboardSpendSummary> cardSpendSummary({required DateTime asOf}) async {
    final cards = await _creditCards.listActive();
    final spendByCardId = await cardSpendByCardId(asOf: asOf);

    final rows = <DashboardCardSpend>[];
    var totalPaise = 0;

    for (final card in cards) {
      final spentPaise = spendByCardId[card.id] ?? 0;
      totalPaise += spentPaise;
      rows.add(
        DashboardCardSpend(
          nickname: card.nickname,
          spentPaise: spentPaise,
        ),
      );
    }

    rows.sort((a, b) => b.spentPaise.compareTo(a.spentPaise));

    return DashboardSpendSummary(
      totalPaise: totalPaise,
      cards: rows,
    );
  }

  Future<Map<int, int>> cardSpendByCardId({required DateTime asOf}) =>
      _spendByCard(asOf: asOf);

  Future<Map<int, int>> _spendByCard({required DateTime asOf}) async {
    final spendByCardId = <int, int>{};
    final cards = await _creditCards.listActive();
    final currentCycles = await _creditCards.listCurrentCycles(asOf: asOf);
    final cycleByCardId = {
      for (final cycle in currentCycles) cycle.creditCardId: cycle,
    };
    final monthStart = DateTime(asOf.year, asOf.month, 1);
    final monthEnd = DateTime(asOf.year, asOf.month + 1, 0, 23, 59, 59, 999);

    for (final card in cards) {
      final cycle = cycleByCardId[card.id];
      if (cycle != null) {
        final cycleTransactions =
            await _cardTransactions.listForBillingCycleInclusive(
          cardId: card.id,
          cycle: cycle,
        );
        spendByCardId[card.id] = calculateCycleNetSpendPaise(cycleTransactions);
        continue;
      }

      final transactions = await _cardTransactions.listForCard(card.id);
      final monthTransactions = transactions.where(
        (transaction) =>
            !transaction.transactionAt.isBefore(monthStart) &&
            !transaction.transactionAt.isAfter(monthEnd),
      );
      spendByCardId[card.id] = calculateCycleNetSpendPaise(monthTransactions);
    }

    return spendByCardId;
  }

  Future<List<DashboardRecentTransaction>> recentTransactions({
    int limit = 8,
  }) async {
    final rows = await _cardTransactions.listPage(offset: 0, limit: limit);
    final cards = await _creditCards.listActive();
    final nicknameById = {
      for (final card in cards) card.id: card.nickname,
    };
    final colorById = {for (final card in cards) card.id: card.colorValue};

    return rows
        .map(
          (tx) => DashboardRecentTransaction(
            id: tx.id,
            merchant: tx.merchant,
            amountPaise: tx.amountPaise,
            transactionAt: tx.transactionAt,
            colorValue: colorById[tx.creditCardId] ?? 0xFF9E9E9E,
            cardNickname:
                nicknameById[tx.creditCardId] ?? 'Card ${tx.creditCardId}',
            kind: tx.kind,
          ),
        )
        .toList();
  }
}
