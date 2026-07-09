import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/engine/budget_spend.dart';

void main() {
  group('Category spend', () {
    test('totals personal spend by category', () {
      final totals = calculateCategorySpendPaise([
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 30000,
          category: 'Food',
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 20000,
          category: 'Food',
        ),
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: true,
          amountPaise: 15000,
          category: 'Food',
        ),
      ]);

      expect(totals['Food'], 50000);
    });

    test('defaults missing category to Miscellaneous', () {
      final totals = calculateCategorySpendPaise([
        const BudgetTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 12000,
        ),
      ]);

      expect(totals['Miscellaneous'], 12000);
    });
  });
}
