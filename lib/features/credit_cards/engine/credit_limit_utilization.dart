import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/home_widgets/domain/card_utilization_segment.dart';

class CreditUtilizationResult {
  const CreditUtilizationResult({
    required this.spentPaise,
    required this.creditLimitPaise,
    required this.needsLimitPrompt,
    required this.cardSegments,
  });

  final int spentPaise;
  final int? creditLimitPaise;
  final bool needsLimitPrompt;
  final List<CardUtilizationSegment> cardSegments;
}

bool cardHasConfiguredCreditLimit(CreditCard card) {
  return card.creditLimitPaise != null || card.creditLimitPoolId != null;
}

CreditUtilizationResult buildCreditUtilization({
  required List<CreditCard> cards,
  required Map<int, CreditLimitPool> poolsById,
  required Map<int, int> spendByCardId,
  required int totalSpentPaise,
}) {
  if (cards.isEmpty) {
    return const CreditUtilizationResult(
      spentPaise: 0,
      creditLimitPaise: null,
      needsLimitPrompt: false,
      cardSegments: [],
    );
  }

  final needsLimitPrompt =
      cards.any((card) => !cardHasConfiguredCreditLimit(card));
  final segments = _buildSegments(
    cards: cards,
    poolsById: poolsById,
    spendByCardId: spendByCardId,
  );

  return CreditUtilizationResult(
    spentPaise: totalSpentPaise,
    creditLimitPaise: needsLimitPrompt
        ? null
        : _totalConfiguredCreditLimit(cards: cards, poolsById: poolsById),
    needsLimitPrompt: needsLimitPrompt,
    cardSegments: segments,
  );
}

int _totalConfiguredCreditLimit({
  required List<CreditCard> cards,
  required Map<int, CreditLimitPool> poolsById,
}) {
  var total = 0;
  final countedPools = <int>{};

  for (final card in cards) {
    final poolId = card.creditLimitPoolId;
    if (poolId != null) {
      if (countedPools.add(poolId)) {
        total += poolsById[poolId]?.creditLimitPaise ?? 0;
      }
      continue;
    }

    total += card.creditLimitPaise ?? 0;
  }

  return total;
}

List<CardUtilizationSegment> _buildSegments({
  required List<CreditCard> cards,
  required Map<int, CreditLimitPool> poolsById,
  required Map<int, int> spendByCardId,
}) {
  final segments = <CardUtilizationSegment>[];
  final processedPools = <int>{};

  for (final card in cards) {
    final poolId = card.creditLimitPoolId;
    if (poolId != null) {
      if (processedPools.contains(poolId)) {
        continue;
      }
      processedPools.add(poolId);

      final pool = poolsById[poolId];
      if (pool == null) {
        continue;
      }

      final poolSpend = cards
          .where((candidate) => candidate.creditLimitPoolId == poolId)
          .fold<int>(0, (sum, candidate) => sum + (spendByCardId[candidate.id] ?? 0));

      segments.add(
        CardUtilizationSegment(
          cardId: card.id,
          nickname: pool.name,
          spentPaise: poolSpend,
          creditLimitPaise: pool.creditLimitPaise,
          colorValue: card.colorValue,
          isSharedPool: true,
        ),
      );
      continue;
    }

    final limit = card.creditLimitPaise;
    if (limit == null) {
      continue;
    }

    segments.add(
      CardUtilizationSegment(
        cardId: card.id,
        nickname: card.nickname,
        spentPaise: spendByCardId[card.id] ?? 0,
        creditLimitPaise: limit,
        colorValue: card.colorValue,
      ),
    );
  }

  segments.sort((a, b) => b.spentPaise.compareTo(a.spentPaise));
  return segments;
}
