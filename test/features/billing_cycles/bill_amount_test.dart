import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';

void main() {
  group('Bill Amount', () {
    test('sums expenses and adjustment charges', () {
      final amount = calculateBillAmount([
        const CardTransactionLine(
          kind: CardTransactionKind.expense,
          amountPaise: 50000,
        ),
        const CardTransactionLine(
          kind: CardTransactionKind.adjustmentCharge,
          amountPaise: 2500,
        ),
      ]);

      expect(amount, 52500);
    });

    test('subtracts refunds, cashbacks, and adjustment credits', () {
      final amount = calculateBillAmount([
        const CardTransactionLine(
          kind: CardTransactionKind.expense,
          amountPaise: 100000,
        ),
        const CardTransactionLine(
          kind: CardTransactionKind.refund,
          amountPaise: 20000,
        ),
        const CardTransactionLine(
          kind: CardTransactionKind.cashback,
          amountPaise: 500,
        ),
        const CardTransactionLine(
          kind: CardTransactionKind.adjustmentCredit,
          amountPaise: 1500,
        ),
      ]);

      expect(amount, 78000);
    });

    test('excludes card payments from bill amount', () {
      final amount = calculateBillAmount([
        const CardTransactionLine(
          kind: CardTransactionKind.expense,
          amountPaise: 40000,
        ),
        const CardTransactionLine(
          kind: CardTransactionKind.cardPayment,
          amountPaise: 40000,
        ),
      ]);

      expect(amount, 40000);
    });
  });
}
