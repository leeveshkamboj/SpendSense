enum BankTransactionKind {
  debit,
  credit,
}

class ParsedBankTransaction {
  const ParsedBankTransaction({
    required this.bank,
    required this.lastFourDigits,
    required this.kind,
    required this.amountPaise,
    required this.transactionAt,
    required this.rawSms,
    this.merchant,
    this.beneficiary,
    this.category,
    this.referenceNumber,
  });

  final String bank;
  final String lastFourDigits;
  final BankTransactionKind kind;
  final int amountPaise;
  final DateTime transactionAt;
  final String rawSms;
  final String? merchant;
  final String? beneficiary;
  final String? category;
  final String? referenceNumber;
}
