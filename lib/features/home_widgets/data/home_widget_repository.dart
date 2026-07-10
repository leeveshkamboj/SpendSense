import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/budgets/engine/budget_spend.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_repository.dart';
import 'package:spendsense/features/credit_cards/engine/credit_limit_utilization.dart';
import 'package:spendsense/features/dashboard/data/dashboard_repository.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/home_widgets/domain/card_spend_chart_segment.dart';
import 'package:spendsense/features/home_widgets/domain/bills_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/budget_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/credit_utilization_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/quick_summary_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/recent_transactions_widget_snapshot.dart';

class HomeWidgetRepository {
  HomeWidgetRepository({
    required DashboardRepository dashboard,
    required BudgetRepository budgets,
    required CreditCardRepository creditCards,
    required CreditLimitPoolRepository creditLimitPools,
    required BillsRepository bills,
  })  : _dashboard = dashboard,
        _budgets = budgets,
        _creditCards = creditCards,
        _creditLimitPools = creditLimitPools,
        _bills = bills;

  final DashboardRepository _dashboard;
  final BudgetRepository _budgets;
  final CreditCardRepository _creditCards;
  final CreditLimitPoolRepository _creditLimitPools;
  final BillsRepository _bills;

  Future<QuickSummaryWidgetSnapshot> quickSummary({
    required DateTime asOf,
  }) async {
    final progress = await _budgets.monthlyProgress(asOf: asOf);
    final cards = await _creditCards.listActive();

    if (progress == null) {
      return QuickSummaryWidgetSnapshot(
        spentPaise: 0,
        budgetLimitPaise: null,
        budgetRemainingPaise: null,
        cardSpendSegments: const [],
      );
    }

    final periodTransactions =
        await _budgets.listBudgetPeriodTransactions(asOf: asOf);
    final budgetCardSpend = calculateCardSpendPaise(periodTransactions);
    final cardSpendSegments = [
      for (final card in cards)
        CardSpendChartSegment(
          nickname: card.nickname,
          spentPaise: budgetCardSpend[card.id] ?? 0,
          colorValue: card.colorValue,
        ),
    ]..sort((a, b) => b.spentPaise.compareTo(a.spentPaise));

    return QuickSummaryWidgetSnapshot(
      spentPaise: progress.spentPaise,
      budgetLimitPaise: progress.limitPaise,
      budgetRemainingPaise: progress.remainingPaise,
      cardSpendSegments: cardSpendSegments,
    );
  }

  Future<CreditUtilizationWidgetSnapshot> creditUtilization({
    required DateTime asOf,
  }) async {
    final spend = await _dashboard.cardSpendSummary(asOf: asOf);
    final spendByCardId = await _dashboard.cardSpendByCardId(asOf: asOf);
    final cards = await _creditCards.listActive();
    final pools = await _creditLimitPools.listAll();
    final poolsById = {for (final pool in pools) pool.id: pool};
    final utilization = buildCreditUtilization(
      cards: cards,
      poolsById: poolsById,
      spendByCardId: spendByCardId,
      totalSpentPaise: spend.totalPaise,
    );

    return CreditUtilizationWidgetSnapshot(
      spentPaise: utilization.spentPaise,
      creditLimitPaise: utilization.creditLimitPaise,
      needsLimitPrompt: utilization.needsLimitPrompt,
      cardSegments: utilization.cardSegments,
    );
  }

  Future<RecentTransactionsWidgetSnapshot> recentTransactions({
    int limit = 5,
  }) async {
    final rows = await _dashboard.recentTransactions(limit: limit);

    return RecentTransactionsWidgetSnapshot(
      transactions: [
        for (final row in rows)
          RecentTransactionWidgetItem(
            transactionId: row.id,
            merchant: row.merchant,
            amountPaise: row.amountPaise,
            transactionAt: row.transactionAt,
            colorValue: row.colorValue,
            kind: row.kind,
          ),
      ],
    );
  }

  Future<BillsWidgetSnapshot> upcomingBills({
    required DateTime asOf,
    int limit = 5,
  }) async {
    final rows = await _bills.listUnpaidBills(asOf: asOf);
    final cards = await _creditCards.listActive();
    final colorById = {for (final card in cards) card.id: card.colorValue};

    return BillsWidgetSnapshot(
      bills: [
        for (final bill in rows.take(limit))
          BillWidgetItem(
            creditCardId: bill.creditCardId,
            cycleId: bill.cycleId,
            cardNickname: bill.cardNickname,
            dueDate: bill.dueDate,
            netOutstandingPaise: bill.netOutstandingPaise,
            colorValue: colorById[bill.creditCardId] ?? 0xFF9E9E9E,
          ),
      ],
    );
  }

  Future<BudgetWidgetSnapshot> budgetProgress({required DateTime asOf}) async {
    final spend = await _dashboard.cardSpendSummary(asOf: asOf);
    final cards = await _creditCards.listActive();
    final progress = await _budgets.monthlyProgress(asOf: asOf);
    if (progress == null) {
      return BudgetWidgetSnapshot(
        spentPaise: spend.totalPaise,
        limitPaise: null,
        remainingPaise: null,
        dailyBudgetPaise: null,
        needsBudgetPrompt: true,
        cardSpendSegments: _cardSpendSegments(spend, cards),
      );
    }

    final asOfDay = DateTime(asOf.year, asOf.month, asOf.day);
    final periodEnd = DateTime(
      progress.periodEnd.year,
      progress.periodEnd.month,
      progress.periodEnd.day,
    );
    final daysRemaining = periodEnd.difference(asOfDay).inDays + 1;
    final remaining = progress.remainingPaise;
    final dailyBudget = daysRemaining > 0 ? remaining ~/ daysRemaining : remaining;
    final periodTransactions =
        await _budgets.listBudgetPeriodTransactions(asOf: asOf);
    final budgetCardSpend = calculateCardSpendPaise(periodTransactions);
    final cardSpendSegments = [
      for (final card in cards)
        CardSpendChartSegment(
          nickname: card.nickname,
          spentPaise: budgetCardSpend[card.id] ?? 0,
          colorValue: card.colorValue,
        ),
    ]..sort((a, b) => b.spentPaise.compareTo(a.spentPaise));

    return BudgetWidgetSnapshot(
      spentPaise: progress.spentPaise,
      limitPaise: progress.limitPaise,
      remainingPaise: remaining,
      dailyBudgetPaise: dailyBudget,
      needsBudgetPrompt: false,
      cardSpendSegments: cardSpendSegments,
    );
  }

  List<CardSpendChartSegment> _cardSpendSegments(
    DashboardSpendSummary spend,
    List<CreditCard> cards,
  ) {
    final colorByNickname = {
      for (final card in cards) card.nickname: card.colorValue,
    };

    return [
      for (final row in spend.cards)
        CardSpendChartSegment(
          nickname: row.nickname,
          spentPaise: row.spentPaise,
          colorValue: colorByNickname[row.nickname] ?? 0xFF9E9E9E,
        ),
    ];
  }
}
