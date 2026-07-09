class CapturedTransactionSnapshot {
  const CapturedTransactionSnapshot({
    this.creditCardId,
    this.bankAccountId,
    required this.amountPaise,
    required this.merchant,
    required this.transactionAt,
    this.referenceNumber,
  }) : assert(creditCardId != null || bankAccountId != null);

  final int? creditCardId;
  final int? bankAccountId;
  final int amountPaise;
  final String merchant;
  final DateTime transactionAt;
  final String? referenceNumber;
}
