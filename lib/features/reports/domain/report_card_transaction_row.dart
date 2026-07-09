class ReportCardTransactionRow {
  const ReportCardTransactionRow({
    required this.id,
    required this.creditCardId,
    required this.cardNickname,
    required this.billingCycleId,
    required this.kind,
    required this.amountPaise,
    required this.merchant,
    required this.transactionAt,
    required this.source,
    required this.referenceNumber,
    required this.category,
    required this.isRecoverable,
    required this.recoverablePerson,
    required this.isReviewed,
    required this.notes,
    required this.location,
    required this.createdAt,
  });

  final int id;
  final int creditCardId;
  final String cardNickname;
  final int? billingCycleId;
  final String kind;
  final int amountPaise;
  final String merchant;
  final DateTime transactionAt;
  final String source;
  final String? referenceNumber;
  final String? category;
  final bool isRecoverable;
  final String? recoverablePerson;
  final bool isReviewed;
  final String? notes;
  final String? location;
  final DateTime createdAt;
}
