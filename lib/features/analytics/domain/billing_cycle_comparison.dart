class BillingCycleComparison {
  const BillingCycleComparison({
    required this.cardNickname,
    required this.currentCycleLabel,
    required this.previousCycleLabel,
    required this.currentSpendPaise,
    required this.previousSpendPaise,
  });

  final String cardNickname;
  final String currentCycleLabel;
  final String previousCycleLabel;
  final int currentSpendPaise;
  final int previousSpendPaise;
}
