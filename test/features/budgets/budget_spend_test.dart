import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/engine/budget_spend.dart';

void main() {
  group('Budget spend', () {
    test('sums personal credit card expenses only', () {
      final total = calculatePersonalSpendPaise([
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 50000,
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: true,
          amountPaise: 10000,
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.bankAccount,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 20000,
        ),
      ]);

      expect(total, 50000);
    });

    test('sums personal card spend per card excluding recoverables', () {
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
          amountPaise: 10000,
          cardId: 1,
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 20000,
          cardId: 2,
        ),
      ]);

      expect(totals[1], 50000);
      expect(totals[2], 20000);
    });
  });
}
