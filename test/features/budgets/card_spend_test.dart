import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/engine/budget_spend.dart';

void main() {
  group('Card spend', () {
    test('totals credit card expenses per card including recoverables', () {
      final totals = calculateCardSpendPaise([
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 50000,
          cardId: 1,
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: true,
          amountPaise: 30000,
          cardId: 2,
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.bankAccount,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 20000,
          cardId: 3,
        ),
      ]);

      expect(totals[1], 50000);
      expect(totals[2], 30000);
      expect(totals.containsKey(3), isFalse);
    });
  });
}
