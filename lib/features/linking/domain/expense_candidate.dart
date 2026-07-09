class ExpenseCandidate {
  const ExpenseCandidate({
    required this.transactionId,
    required this.cardId,
    required this.merchant,
    required this.amountPaise,
    required this.billingCycleId,
  });

  final int transactionId;
  final int cardId;
  final String merchant;
  final int amountPaise;
  final int? billingCycleId;
}
