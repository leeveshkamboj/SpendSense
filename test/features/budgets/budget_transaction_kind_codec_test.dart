import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction_kind_codec.dart';

void main() {
  group('budgetTransactionKindFromString', () {
    test('does not treat card payments or cashbacks as expenses', () {
      expect(
        budgetTransactionKindFromString('card_payment'),
        BudgetTransactionKind.cardPayment,
      );
      expect(
        budgetTransactionKindFromString('cashback'),
        BudgetTransactionKind.refund,
      );
    });
  });
}
