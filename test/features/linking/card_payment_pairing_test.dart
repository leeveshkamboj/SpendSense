import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/linking/domain/card_payment_candidate.dart';
import 'package:spendsense/features/linking/engine/card_payment_pairing.dart';

void main() {
  group('Card payment pairing', () {
    final at = DateTime(2026, 7, 9, 18);

    test('pairs bank debit with card payment by amount and time', () {
      final match = findCardPaymentPair(
        incoming: CardPaymentCandidate(
          transactionId: 1,
          source: CardPaymentSource.bankDebit,
          amountPaise: 500000,
          transactionAt: at,
        ),
        candidates: [
          CardPaymentCandidate(
            transactionId: 2,
            source: CardPaymentSource.cardPayment,
            amountPaise: 500000,
            transactionAt: at.add(const Duration(minutes: 1)),
          ),
        ],
      );

      expect(match?.pairedTransactionId, 2);
    });
  });
}
