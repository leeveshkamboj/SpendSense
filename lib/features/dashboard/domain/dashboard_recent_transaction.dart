class DashboardRecentTransaction {
  const DashboardRecentTransaction({
    required this.merchant,
    required this.amountPaise,
    required this.transactionAt,
  });

  final String merchant;
  final int amountPaise;
  final DateTime transactionAt;
}
