class RecoveryAllocation {
  const RecoveryAllocation({
    required this.creditTransactionId,
    required this.recoverableTransactionId,
    required this.amountPaise,
  });

  final int creditTransactionId;
  final int recoverableTransactionId;
  final int amountPaise;
}
