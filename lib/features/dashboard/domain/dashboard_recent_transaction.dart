class DashboardRecentTransaction {
  const DashboardRecentTransaction({
    required this.merchant,
    required this.amountPaise,
    required this.transactionAt,
    required this.colorValue,
  });

  final String merchant;
  final int amountPaise;
  final DateTime transactionAt;
  final int colorValue;
}
