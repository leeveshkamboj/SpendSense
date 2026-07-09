class BillingCyclePeriod {
  const BillingCyclePeriod({
    required this.startDate,
    required this.endDate,
  });

  /// Day after the previous bill generation date (inclusive).
  final DateTime startDate;

  /// Bill generation date for this cycle (inclusive).
  final DateTime endDate;
}
