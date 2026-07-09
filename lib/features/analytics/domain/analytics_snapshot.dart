class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.currentPeriodStart,
    required this.previousPeriodStart,
    required this.currentCategoryTotals,
    required this.previousCategoryTotals,
    required this.currentMerchantTotals,
    required this.previousMerchantTotals,
    required this.currentCardTotals,
    required this.previousCardTotals,
    required this.currentTagTotals,
    required this.previousTagTotals,
  });

  final DateTime currentPeriodStart;
  final DateTime previousPeriodStart;
  final Map<String, int> currentCategoryTotals;
  final Map<String, int> previousCategoryTotals;
  final Map<String, int> currentMerchantTotals;
  final Map<String, int> previousMerchantTotals;
  final Map<String, int> currentCardTotals;
  final Map<String, int> previousCardTotals;
  final Map<String, int> currentTagTotals;
  final Map<String, int> previousTagTotals;
}
