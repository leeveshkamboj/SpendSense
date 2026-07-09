import 'package:spendsense/features/home_widgets/domain/card_utilization_segment.dart';

class CreditUtilizationWidgetSnapshot {
  const CreditUtilizationWidgetSnapshot({
    required this.spentPaise,
    required this.creditLimitPaise,
    required this.needsLimitPrompt,
    required this.cardSegments,
  });

  final int spentPaise;
  final int? creditLimitPaise;
  final bool needsLimitPrompt;
  final List<CardUtilizationSegment> cardSegments;
}
