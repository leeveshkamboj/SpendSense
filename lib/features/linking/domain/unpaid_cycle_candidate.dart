class UnpaidCycleCandidate {
  const UnpaidCycleCandidate({
    required this.cycleId,
    required this.endDate,
    required this.outstandingPaise,
  });

  final int cycleId;
  final DateTime endDate;
  final int outstandingPaise;
}
