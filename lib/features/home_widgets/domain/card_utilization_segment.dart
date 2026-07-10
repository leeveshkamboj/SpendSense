class CardUtilizationSegment {
  const CardUtilizationSegment({
    required this.cardId,
    required this.nickname,
    required this.spentPaise,
    required this.creditLimitPaise,
    required this.colorValue,
    this.isSharedPool = false,
  });

  final int cardId;
  final String nickname;
  final int spentPaise;
  final int creditLimitPaise;
  final int colorValue;
  final bool isSharedPool;
}
