enum BudgetTransactionSource {
  creditCard,
  bankAccount,
}

enum BudgetTransactionKind {
  expense,
  refund,
  cardPayment,
}

class BudgetTransaction {
  const BudgetTransaction({
    required this.source,
    required this.kind,
    required this.isRecoverable,
    this.amountPaise = 0,
    this.category,
    this.transactionAt,
    this.cardBillDayOfMonth,
    this.cardId,
  });

  final BudgetTransactionSource source;
  final BudgetTransactionKind kind;
  final bool isRecoverable;
  final int amountPaise;
  final String? category;
  final DateTime? transactionAt;
  final int? cardBillDayOfMonth;
  final int? cardId;
}
