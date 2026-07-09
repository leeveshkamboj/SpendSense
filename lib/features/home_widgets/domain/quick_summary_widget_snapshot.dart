import 'package:spendsense/features/home_widgets/domain/card_spend_chart_segment.dart';

class QuickSummaryWidgetSnapshot {
  const QuickSummaryWidgetSnapshot({
    required this.spentPaise,
    required this.budgetLimitPaise,
    required this.budgetRemainingPaise,
    required this.cardSpendSegments,
  });

  final int spentPaise;
  final int? budgetLimitPaise;
  final int? budgetRemainingPaise;
  final List<CardSpendChartSegment> cardSpendSegments;
}
