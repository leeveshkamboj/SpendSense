class DashboardCardSpend {
  const DashboardCardSpend({
    required this.nickname,
    required this.spentPaise,
    this.cardNetwork,
  });

  final String nickname;
  final int spentPaise;
  final String? cardNetwork;
}

class DashboardSpendSummary {
  const DashboardSpendSummary({
    required this.totalPaise,
    required this.cards,
  });

  final int totalPaise;
  final List<DashboardCardSpend> cards;
}
