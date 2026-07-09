import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/budgets/engine/budget_spend.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_recent_transaction.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class DashboardRepository {
  DashboardRepository({
    required AppDatabase database,
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
    required BudgetRepository budgets,
  })  : _creditCards = creditCards,
        _cardTransactions = cardTransactions,
        _budgets = budgets;

  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;
  final BudgetRepository _budgets;

  Future<DashboardSpendSummary> cardSpendSummary({required DateTime asOf}) async {
    final periodTransactions =
        await _budgets.listBudgetPeriodTransactions(asOf: asOf);
    final spendByCardId = calculateCardSpendPaise(periodTransactions);
    final cards = await _creditCards.listActive();
    final nicknameById = {
      for (final card in cards) card.id: card.nickname,
    };

    final rows = <DashboardCardSpend>[];
    var totalPaise = 0;

    for (final entry in spendByCardId.entries) {
      final spentPaise = entry.value;
      totalPaise += spentPaise;
      rows.add(
        DashboardCardSpend(
          nickname: nicknameById[entry.key] ?? 'Card ${entry.key}',
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

  Future<List<DashboardRecentTransaction>> recentTransactions({
    int limit = 5,
  }) async {
    final rows = await _cardTransactions.listPage(offset: 0, limit: limit);
    final cards = await _creditCards.listActive();
    final colorById = {for (final card in cards) card.id: card.colorValue};

    return rows
        .map(
          (tx) => DashboardRecentTransaction(
            merchant: tx.merchant,
            amountPaise: tx.amountPaise,
            transactionAt: tx.transactionAt,
            colorValue: colorById[tx.creditCardId] ?? 0xFF9E9E9E,
          ),
        )
        .toList();
  }
}
