class DashboardRecentTransaction {
  const DashboardRecentTransaction({
    required this.merchant,
    required this.amountPaise,
    required this.transactionAt,
    required this.colorValue,
    required this.cardNickname,
    required this.kind,
  });

  final String merchant;
  final int amountPaise;
  final DateTime transactionAt;
  final int colorValue;
  final String cardNickname;
  final String kind;
}
