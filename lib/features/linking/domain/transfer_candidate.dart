enum TransferSideKind {
  debit,
  credit,
}

class TransferCandidate {
  const TransferCandidate({
    required this.transactionId,
    required this.accountId,
    required this.kind,
    required this.amountPaise,
    required this.transactionAt,
    this.isLinked = false,
  });

  final int transactionId;
  final int accountId;
  final TransferSideKind kind;
  final int amountPaise;
  final DateTime transactionAt;
  final bool isLinked;
}

class TransferPair {
  const TransferPair({required this.pairedTransactionId});

  final int pairedTransactionId;
}
