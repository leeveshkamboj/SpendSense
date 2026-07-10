import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';

void main() {
  group('cardTransactionKindFromString', () {
    test('maps snake_case database kinds', () {
      expect(
        cardTransactionKindFromString('card_payment'),
        CardTransactionKind.cardPayment,
      );
      expect(
        cardTransactionKindFromString('adjustment_charge'),
        CardTransactionKind.adjustmentCharge,
      );
      expect(
        cardTransactionKindFromString('adjustment_credit'),
        CardTransactionKind.adjustmentCredit,
      );
    });

    test('maps standard kinds', () {
      expect(
        cardTransactionKindFromString('expense'),
        CardTransactionKind.expense,
      );
      expect(
        cardTransactionKindFromString('refund'),
        CardTransactionKind.refund,
      );
      expect(
        cardTransactionKindFromString('cashback'),
        CardTransactionKind.cashback,
      );
    });
  });
}
