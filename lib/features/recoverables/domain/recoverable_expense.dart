class RecoverableExpense {
  const RecoverableExpense({
    required this.transactionId,
    required this.person,
    required this.amountPaise,
  });

  final int transactionId;
  final String person;
  final int amountPaise;
}
