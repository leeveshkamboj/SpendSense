class CardSpendChartSegment {
  const CardSpendChartSegment({
    required this.nickname,
    required this.spentPaise,
    required this.colorValue,
    this.cardNetwork,
  });

  final String nickname;
  final int spentPaise;
  final int colorValue;
  final String? cardNetwork;
}
