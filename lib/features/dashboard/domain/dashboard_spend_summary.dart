class DashboardCardSpend {
  const DashboardCardSpend({
    required this.nickname,
    required this.spentPaise,
  });

  final String nickname;
  final int spentPaise;
}

class DashboardSpendSummary {
  const DashboardSpendSummary({
    required this.totalPaise,
    required this.cards,
  });

  final int totalPaise;
  final List<DashboardCardSpend> cards;
}
