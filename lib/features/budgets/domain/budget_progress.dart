class BudgetProgressSnapshot {
  const BudgetProgressSnapshot({
    required this.limitPaise,
    required this.spentPaise,
    required this.projectedPaise,
    required this.periodStart,
    required this.periodEnd,
  });

  final int limitPaise;
  final int spentPaise;
  final int projectedPaise;
  final DateTime periodStart;
  final DateTime periodEnd;

  int get remainingPaise => limitPaise - spentPaise;

  double get usedFraction => limitPaise == 0 ? 0 : spentPaise / limitPaise;
}
