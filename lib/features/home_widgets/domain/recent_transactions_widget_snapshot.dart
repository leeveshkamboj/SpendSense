class RecentTransactionWidgetItem {
  const RecentTransactionWidgetItem({
    required this.merchant,
    required this.amountPaise,
    required this.transactionAt,
    required this.colorValue,
    required this.kind,
  });

  final String merchant;
  final int amountPaise;
  final DateTime transactionAt;
  final int colorValue;
  final String kind;
}

class RecentTransactionsWidgetSnapshot {
  const RecentTransactionsWidgetSnapshot({required this.transactions});

  final List<RecentTransactionWidgetItem> transactions;
}
