import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/analytics/domain/analytics_snapshot.dart';
import 'package:spendsense/features/analytics/domain/analytics_transaction.dart';
import 'package:spendsense/features/analytics/domain/billing_cycle_comparison.dart';
import 'package:spendsense/features/analytics/engine/analytics_breakdown.dart';
import 'package:spendsense/features/analytics/engine/analytics_period.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class AnalyticsRepository {
  AnalyticsRepository({
    required BudgetRepository budgets,
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
    required TagRepository tags,
  })  : _budgets = budgets,
        _creditCards = creditCards,
        _cardTransactions = cardTransactions,
        _tags = tags;

  final BudgetRepository _budgets;
  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;
  final TagRepository _tags;

  Future<AnalyticsSnapshot> snapshot({required DateTime asOf}) async {
    final currentStart = await _budgets.currentBudgetPeriodStart(asOf: asOf);
    final previousStart = await _budgets.previousBudgetPeriodStart(asOf: asOf);
    final allTransactions = await _loadAnalyticsTransactions();

    final current = await _transactionsForPeriod(
      allTransactions: allTransactions,
      asOf: asOf,
      periodStart: currentStart,
    );
    final previous = await _transactionsForPeriod(
      allTransactions: allTransactions,
      asOf: asOf,
      periodStart: previousStart,
    );

    return AnalyticsSnapshot(
      currentPeriodStart: currentStart,
      previousPeriodStart: previousStart,
      currentCategoryTotals: calculateCategoryAnalytics(current),
      previousCategoryTotals: calculateCategoryAnalytics(previous),
      currentMerchantTotals: calculateMerchantAnalytics(current),
      previousMerchantTotals: calculateMerchantAnalytics(previous),
      currentCardTotals: calculateCardAnalytics(current),
      previousCardTotals: calculateCardAnalytics(previous),
      currentTagTotals: calculateTagAnalytics(current),
      previousTagTotals: calculateTagAnalytics(previous),
    );
  }

  Future<BillingCycleComparison?> billingCycleComparison({
    required int creditCardId,
    required DateTime asOf,
  }) async {
    final card = await _creditCards.getById(creditCardId);
    if (card == null || card.billDayOfMonth == null) {
      return null;
    }

    final cycles = await _creditCards.listCycles(creditCardId);
    if (cycles.isEmpty) {
      return null;
    }

    final sortedCycles = List<BillingCycle>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final currentPeriod = billingCycleContaining(
      transactionDate: asOf,
      billDayOfMonth: card.billDayOfMonth!,
    );
    final currentCycle = sortedCycles.firstWhere(
      (cycle) =>
          _sameDay(cycle.startDate, currentPeriod.startDate) &&
          _sameDay(cycle.endDate, currentPeriod.endDate),
      orElse: () => sortedCycles.last,
    );
    final currentIndex =
        sortedCycles.indexWhere((cycle) => cycle.id == currentCycle.id);
    if (currentIndex <= 0) {
      return null;
    }

    final previousCycle = sortedCycles[currentIndex - 1];
    final currentSpend = await _cycleExpenseSpend(currentCycle.id);
    final previousSpend = await _cycleExpenseSpend(previousCycle.id);

    return BillingCycleComparison(
      cardNickname: card.nickname,
      currentCycleLabel: formatBillingCycleLabel(
        currentCycle.startDate,
        currentCycle.endDate,
      ),
      previousCycleLabel: formatBillingCycleLabel(
        previousCycle.startDate,
        previousCycle.endDate,
      ),
      currentSpendPaise: currentSpend,
      previousSpendPaise: previousSpend,
    );
  }

  Future<List<AnalyticsTransaction>> _loadAnalyticsTransactions() async {
    final cards = await _creditCards.listActive();
    final nicknameById = {for (final card in cards) card.id: card.nickname};
    final transactions = await _cardTransactions.listAll();
    final rows = <AnalyticsTransaction>[];

    for (final transaction in transactions) {
      final tags = await _tags.listForCardTransaction(transaction.id);
      rows.add(
        AnalyticsTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: _kindFromString(transaction.kind),
          isRecoverable: transaction.isRecoverable,
          amountPaise: transaction.amountPaise,
          merchant: transaction.merchant,
          category: transaction.category,
          cardId: transaction.creditCardId,
          cardNickname: nicknameById[transaction.creditCardId],
          transactionAt: transaction.transactionAt,
          tags: tags,
          billingCycleId: transaction.billingCycleId,
        ),
      );
    }

    return rows;
  }

  Future<List<AnalyticsTransaction>> _transactionsForPeriod({
    required List<AnalyticsTransaction> allTransactions,
    required DateTime asOf,
    required DateTime periodStart,
  }) async {
    final budgetRows = await _budgets.listBudgetPeriodTransactions(
      asOf: asOf,
      periodStart: periodStart,
    );
    final keys = budgetRows
        .map(
          (row) => (
            row.cardId,
            row.transactionAt,
            row.amountPaise,
            row.isRecoverable,
          ),
        )
        .toSet();

    return allTransactions
        .where(
          (row) => keys.contains(
            (
              row.cardId,
              row.transactionAt,
              row.amountPaise,
              row.isRecoverable,
            ),
          ),
        )
        .toList();
  }

  Future<int> _cycleExpenseSpend(int billingCycleId) async {
    final transactions =
        await _cardTransactions.listForBillingCycle(billingCycleId);
    return transactions
        .where((tx) => tx.kind == 'expense')
        .fold<int>(0, (sum, tx) => sum + tx.amountPaise);
  }

  BudgetTransactionKind _kindFromString(String kind) {
    return BudgetTransactionKind.values.firstWhere(
      (value) => value.name == kind,
      orElse: () => BudgetTransactionKind.expense,
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
