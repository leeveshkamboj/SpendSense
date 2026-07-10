class DashboardRecentTransaction {
  const DashboardRecentTransaction({
    required this.id,
    required this.merchant,
    required this.amountPaise,
    required this.transactionAt,
    required this.colorValue,
    required this.cardNickname,
    required this.cardNetwork,
    required this.kind,
  });

  final int id;
  final String merchant;
  final int amountPaise;
  final DateTime transactionAt;
  final int colorValue;
  final String cardNickname;
  final String? cardNetwork;
  final String kind;
}
