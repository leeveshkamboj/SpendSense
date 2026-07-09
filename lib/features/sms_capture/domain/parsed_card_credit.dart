enum ParsedCardCreditKind {
  refund,
  cardPayment,
}

class ParsedCardCredit {
  const ParsedCardCredit({
    required this.kind,
    required this.amountPaise,
    required this.bank,
    required this.lastFourDigits,
    required this.transactionAt,
    required this.rawSms,
    this.merchant,
    this.referenceNumber,
  });

  final ParsedCardCreditKind kind;
  final int amountPaise;
  final String bank;
  final String lastFourDigits;
  final DateTime transactionAt;
  final String rawSms;
  final String? merchant;
  final String? referenceNumber;
}
