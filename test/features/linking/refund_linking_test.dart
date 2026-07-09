import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/linking/domain/expense_candidate.dart';
import 'package:spendsense/features/linking/engine/refund_linking.dart';

void main() {
  group('Refund linking', () {
    test('matches refund to original expense by card merchant and amount', () {
      final matchId = findRefundExpenseMatch(
        cardId: 1,
        merchant: 'ZOMATO LTD',
        amountPaise: 41167,
        expenses: [
          ExpenseCandidate(
            transactionId: 10,
            cardId: 1,
            merchant: 'SWIGGY',
            amountPaise: 41167,
            billingCycleId: 5,
          ),
          ExpenseCandidate(
            transactionId: 11,
            cardId: 1,
            merchant: 'ZOMATO LTD',
            amountPaise: 41167,
            billingCycleId: 6,
          ),
        ],
      );

      expect(matchId, 11);
    });

    test('returns null when no matching expense exists', () {
      final matchId = findRefundExpenseMatch(
        cardId: 1,
        merchant: 'ZOMATO LTD',
        amountPaise: 41167,
        expenses: [],
      );

      expect(matchId, isNull);
    });
  });
}
