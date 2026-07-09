enum CardTransactionKind {
  expense,
  refund,
  cashback,
  adjustmentCharge,
  adjustmentCredit,
  cardPayment,
}

class CardTransactionLine {
  const CardTransactionLine({
    required this.kind,
    required this.amountPaise,
  });

  final CardTransactionKind kind;
  final int amountPaise;
}
