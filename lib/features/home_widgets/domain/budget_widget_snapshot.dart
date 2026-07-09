import 'package:spendsense/features/home_widgets/domain/card_spend_chart_segment.dart';

class BudgetWidgetSnapshot {
  const BudgetWidgetSnapshot({
    required this.spentPaise,
    required this.limitPaise,
    required this.remainingPaise,
    required this.dailyBudgetPaise,
    required this.needsBudgetPrompt,
    required this.cardSpendSegments,
  });

  final int spentPaise;
  final int? limitPaise;
  final int? remainingPaise;
  final int? dailyBudgetPaise;
  final bool needsBudgetPrompt;
  final List<CardSpendChartSegment> cardSpendSegments;
}
