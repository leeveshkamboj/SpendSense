bool validateSplitAmounts({
  required int originalAmountPaise,
  required int personalAmountPaise,
  required int recoverableAmountPaise,
}) {
  if (personalAmountPaise + recoverableAmountPaise != originalAmountPaise) {
    throw ArgumentError('Split amounts must sum to the original transaction');
  }

  if (personalAmountPaise <= 0 || recoverableAmountPaise <= 0) {
    throw ArgumentError('Split amounts must be positive');
  }

  return true;
}
