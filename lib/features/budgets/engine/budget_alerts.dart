enum BudgetAlertThreshold {
  seventyFivePercent,
  ninetyPercent,
  oneHundredPercent,
}

const _thresholds = {
  BudgetAlertThreshold.seventyFivePercent: 0.75,
  BudgetAlertThreshold.ninetyPercent: 0.90,
  BudgetAlertThreshold.oneHundredPercent: 1.0,
};

Set<BudgetAlertThreshold> crossedSpendingAlertThresholds({
  required int spentPaise,
  required int limitPaise,
  required Set<BudgetAlertThreshold> previouslyCrossed,
}) {
  if (limitPaise <= 0) {
    return const {};
  }

  final ratio = spentPaise / limitPaise;
  final crossed = <BudgetAlertThreshold>{};

  for (final entry in _thresholds.entries) {
    if (ratio + 1e-9 >= entry.value && !previouslyCrossed.contains(entry.key)) {
      crossed.add(entry.key);
    }
  }

  return crossed;
}
