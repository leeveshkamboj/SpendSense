import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/engine/credit_limit_utilization.dart';

CreditCard _card({
  required int id,
  int? creditLimitPaise,
  int? creditLimitPoolId,
  String nickname = 'Card',
}) {
  return CreditCard(
    id: id,
    bank: 'HDFC',
    lastFourDigits: '5534',
    nickname: nickname,
    network: null,
    creditLimitPaise: creditLimitPaise,
    creditLimitPoolId: creditLimitPoolId,
    billDayOfMonth: 15,
    dueDateOffsetDays: 18,
    colorValue: 0xFF00695C,
    iconName: 'credit_card',
    notes: null,
    isArchived: false,
    createdAt: DateTime(2026, 1, 1),
  );
}

CreditLimitPool _pool({
  required int id,
  required int creditLimitPaise,
  String name = 'Shared pool',
}) {
  return CreditLimitPool(
    id: id,
    name: name,
    creditLimitPaise: creditLimitPaise,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('buildCreditUtilization', () {
    test('counts shared pool limit once for multiple cards', () {
      final cards = [
        _card(id: 1, creditLimitPoolId: 10, nickname: 'HDFC Regalia'),
        _card(id: 2, creditLimitPoolId: 10, nickname: 'HDFC Diners'),
      ];
      final poolsById = {10: _pool(id: 10, creditLimitPaise: 500000)};

      final result = buildCreditUtilization(
        cards: cards,
        poolsById: poolsById,
        spendByCardId: const {1: 100000, 2: 50000},
        totalSpentPaise: 150000,
      );

      expect(result.needsLimitPrompt, isFalse);
      expect(result.creditLimitPaise, 500000);
      expect(result.cardSegments, hasLength(1));
      expect(result.cardSegments.single.isSharedPool, isTrue);
      expect(result.cardSegments.single.spentPaise, 150000);
      expect(result.cardSegments.single.creditLimitPaise, 500000);
    });

    test('combines individual limits with shared pools', () {
      final cards = [
        _card(id: 1, creditLimitPaise: 200000, nickname: 'ICICI'),
        _card(id: 2, creditLimitPoolId: 10, nickname: 'HDFC A'),
        _card(id: 3, creditLimitPoolId: 10, nickname: 'HDFC B'),
      ];

      final result = buildCreditUtilization(
        cards: cards,
        poolsById: {10: _pool(id: 10, creditLimitPaise: 500000)},
        spendByCardId: const {1: 50000, 2: 25000, 3: 25000},
        totalSpentPaise: 100000,
      );

      expect(result.creditLimitPaise, 700000);
      expect(result.cardSegments, hasLength(2));
      expect(
        result.cardSegments.where((segment) => segment.isSharedPool),
        hasLength(1),
      );
    });

    test('prompts when any card lacks a configured limit', () {
      final cards = [
        _card(id: 1, creditLimitPaise: 200000),
        _card(id: 2),
      ];

      final result = buildCreditUtilization(
        cards: cards,
        poolsById: const {},
        spendByCardId: const {1: 50000, 2: 10000},
        totalSpentPaise: 60000,
      );

      expect(result.needsLimitPrompt, isTrue);
      expect(result.creditLimitPaise, isNull);
      expect(result.cardSegments, hasLength(1));
    });
  });
}
