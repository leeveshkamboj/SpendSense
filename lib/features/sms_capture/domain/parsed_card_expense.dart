class ParsedCardExpense {
  const ParsedCardExpense({
    required this.amountPaise,
    required this.merchant,
    required this.bank,
    required this.lastFourDigits,
    required this.transactionAt,
    required this.rawSms,
    this.referenceNumber,
  });

  final int amountPaise;
  final String merchant;
  final String bank;
  final String lastFourDigits;
  final DateTime transactionAt;
  final String rawSms;
  final String? referenceNumber;
}
