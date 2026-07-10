import 'dart:convert';

import 'package:spendsense/features/home_widgets/data/home_widget_writer.dart';
import 'package:spendsense/features/home_widgets/domain/card_spend_chart_segment.dart';
import 'package:spendsense/features/home_widgets/domain/card_utilization_segment.dart';
import 'package:spendsense/features/home_widgets/domain/bills_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/budget_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/credit_utilization_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/quick_summary_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/recent_transactions_widget_snapshot.dart';

class HomeWidgetKeys {
  static const quickSummarySpent = 'quick_summary_spent';
  static const quickSummaryBudgetLimit = 'quick_summary_budget_limit';
  static const quickSummaryRemaining = 'quick_summary_remaining';
  static const quickSummaryCardChartJson = 'quick_summary_card_chart_json';
  static const creditUtilizationSpent = 'credit_utilization_spent';
  static const creditUtilizationLimit = 'credit_utilization_limit';
  static const creditUtilizationNeedsLimit = 'credit_utilization_needs_limit';
  static const creditUtilizationCardsJson = 'credit_utilization_cards_json';
  static const recentTransactionsJson = 'recent_transactions_json';
  static const billsJson = 'bills_json';
  static const budgetSpent = 'budget_spent';
  static const budgetLimit = 'budget_limit';
  static const budgetRemaining = 'budget_remaining';
  static const budgetDaily = 'budget_daily';
  static const budgetNeedsPrompt = 'budget_needs_prompt';
  static const budgetCardChartJson = 'budget_card_chart_json';
}

List<Map<String, Object?>> _encodeCardSpendChart(
  List<CardSpendChartSegment> segments,
) {
  return [
    for (final segment in segments)
      {
        'nickname': segment.nickname,
        'spent_paise': segment.spentPaise,
        'color_value': segment.colorValue,
      },
  ];
}

List<Map<String, Object?>> _encodeCardUtilization(
  List<CardUtilizationSegment> segments,
) {
  return [
    for (final segment in segments)
      {
        'card_id': segment.cardId,
        'nickname': segment.nickname,
        'spent_paise': segment.spentPaise,
        'credit_limit_paise': segment.creditLimitPaise,
        'color_value': segment.colorValue,
      },
  ];
}

class HomeWidgetSyncService {
  HomeWidgetSyncService({required HomeWidgetWriter writer}) : _writer = writer;

  final HomeWidgetWriter _writer;

  Future<void> publishQuickSummary(QuickSummaryWidgetSnapshot snapshot) async {
    await _writer.saveValue(
      HomeWidgetKeys.quickSummarySpent,
      '${snapshot.spentPaise}',
    );
    await _writer.saveValue(
      HomeWidgetKeys.quickSummaryBudgetLimit,
      snapshot.budgetLimitPaise?.toString() ?? '',
    );
    await _writer.saveValue(
      HomeWidgetKeys.quickSummaryRemaining,
      snapshot.budgetRemainingPaise?.toString() ?? '',
    );
    await _writer.saveValue(
      HomeWidgetKeys.quickSummaryCardChartJson,
      jsonEncode(_encodeCardSpendChart(snapshot.cardSpendSegments)),
    );
    await _writer.updateAllWidgets();
  }

  Future<void> publishCreditUtilization(
    CreditUtilizationWidgetSnapshot snapshot,
  ) async {
    await _writer.saveValue(
      HomeWidgetKeys.creditUtilizationSpent,
      '${snapshot.spentPaise}',
    );
    await _writer.saveValue(
      HomeWidgetKeys.creditUtilizationLimit,
      snapshot.creditLimitPaise?.toString() ?? '',
    );
    await _writer.saveValue(
      HomeWidgetKeys.creditUtilizationNeedsLimit,
      '${snapshot.needsLimitPrompt}',
    );
    await _writer.saveValue(
      HomeWidgetKeys.creditUtilizationCardsJson,
      jsonEncode(_encodeCardUtilization(snapshot.cardSegments)),
    );
    await _writer.updateAllWidgets();
  }

  Future<void> publishRecentTransactions(
    RecentTransactionsWidgetSnapshot snapshot,
  ) async {
    final payload = [
      for (final item in snapshot.transactions)
        {
          'transaction_id': item.transactionId,
          'merchant': item.merchant,
          'amount_paise': item.amountPaise,
          'transaction_at_ms': item.transactionAt.millisecondsSinceEpoch,
          'color_value': item.colorValue,
          'kind': item.kind,
        },
    ];
    await _writer.saveValue(
      HomeWidgetKeys.recentTransactionsJson,
      jsonEncode(payload),
    );
    await _writer.updateAllWidgets();
  }

  Future<void> publishBills(BillsWidgetSnapshot snapshot) async {
    final payload = [
      for (final bill in snapshot.bills)
        {
          'credit_card_id': bill.creditCardId,
          'cycle_id': bill.cycleId,
          'card_nickname': bill.cardNickname,
          'due_date_ms': bill.dueDate?.millisecondsSinceEpoch,
          'net_outstanding_paise': bill.netOutstandingPaise,
          'color_value': bill.colorValue,
        },
    ];
    await _writer.saveValue(HomeWidgetKeys.billsJson, jsonEncode(payload));
    await _writer.updateAllWidgets();
  }

  Future<void> publishBudget(BudgetWidgetSnapshot snapshot) async {
    await _writer.saveValue(
      HomeWidgetKeys.budgetSpent,
      '${snapshot.spentPaise}',
    );
    await _writer.saveValue(
      HomeWidgetKeys.budgetLimit,
      snapshot.limitPaise?.toString() ?? '',
    );
    await _writer.saveValue(
      HomeWidgetKeys.budgetRemaining,
      snapshot.remainingPaise?.toString() ?? '',
    );
    await _writer.saveValue(
      HomeWidgetKeys.budgetDaily,
      snapshot.dailyBudgetPaise?.toString() ?? '',
    );
    await _writer.saveValue(
      HomeWidgetKeys.budgetNeedsPrompt,
      '${snapshot.needsBudgetPrompt}',
    );
    await _writer.saveValue(
      HomeWidgetKeys.budgetCardChartJson,
      jsonEncode(_encodeCardSpendChart(snapshot.cardSpendSegments)),
    );
    await _writer.updateAllWidgets();
  }
}
