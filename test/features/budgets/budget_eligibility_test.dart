import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/engine/budget_eligibility.dart';

void main() {
  group('Budget eligibility', () {
    test('counts credit card expenses toward budget', () {
      expect(
        countsTowardBudget(
          const BudgetTransaction(
            source: BudgetTransactionSource.creditCard,
            kind: BudgetTransactionKind.expense,
            isRecoverable: false,
          ),
        ),
        isTrue,
      );
    });

    test('excludes recoverable credit card expenses', () {
      expect(
        countsTowardBudget(
          const BudgetTransaction(
            source: BudgetTransactionSource.creditCard,
            kind: BudgetTransactionKind.expense,
            isRecoverable: true,
          ),
        ),
        isFalse,
      );
    });

    test('excludes bank account transactions', () {
      expect(
        countsTowardBudget(
          const BudgetTransaction(
            source: BudgetTransactionSource.bankAccount,
            kind: BudgetTransactionKind.expense,
            isRecoverable: false,
          ),
        ),
        isFalse,
      );
    });

    test('excludes refunds and card payments', () {
      expect(
        countsTowardBudget(
          const BudgetTransaction(
            source: BudgetTransactionSource.creditCard,
            kind: BudgetTransactionKind.refund,
            isRecoverable: false,
          ),
        ),
        isFalse,
      );
    });
  });
}
