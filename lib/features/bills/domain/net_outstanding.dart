int calculateTotalOutstanding({
  required int billAmountPaise,
  required int paymentsAppliedPaise,
}) {
  return billAmountPaise - paymentsAppliedPaise;
}

int calculateNetOutstanding({
  required int totalOutstandingPaise,
  required int unsettledRecoverablePaise,
}) {
  return totalOutstandingPaise - unsettledRecoverablePaise;
}
