enum CardPaymentSource {
  bankDebit,
  cardPayment,
}

class CardPaymentCandidate {
  const CardPaymentCandidate({
    required this.transactionId,
    required this.source,
    required this.amountPaise,
    required this.transactionAt,
    this.isLinked = false,
  });

  final int transactionId;
  final CardPaymentSource source;
  final int amountPaise;
  final DateTime transactionAt;
  final bool isLinked;
}

class CardPaymentPair {
  const CardPaymentPair({required this.pairedTransactionId});

  final int pairedTransactionId;
}
