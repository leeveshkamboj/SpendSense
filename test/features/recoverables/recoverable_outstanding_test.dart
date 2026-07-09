import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/recoverables/domain/recoverable_expense.dart';
import 'package:spendsense/features/recoverables/domain/recovery_link.dart';
import 'package:spendsense/features/recoverables/engine/recoverable_outstanding.dart';

void main() {
  group('Recoverable outstanding', () {
    const expense = RecoverableExpense(
      transactionId: 1,
      person: 'Rahul',
      amountPaise: 10000,
    );

    test('unsettled amount equals expense when no recoveries linked', () {
      expect(
        unsettledRecoverablePaise(expense: expense, recoveries: const []),
        10000,
      );
    });

    test('unsettled amount subtracts partial recovery links', () {
      expect(
        unsettledRecoverablePaise(
          expense: expense,
          recoveries: const [
            RecoveryAllocation(
              creditTransactionId: 99,
              recoverableTransactionId: 1,
              amountPaise: 4000,
            ),
          ],
        ),
        6000,
      );
    });

    test('fully settled recoverable has zero unsettled amount', () {
      expect(
        unsettledRecoverablePaise(
          expense: expense,
          recoveries: const [
            RecoveryAllocation(
              creditTransactionId: 99,
              recoverableTransactionId: 1,
              amountPaise: 10000,
            ),
          ],
        ),
        0,
      );
    });
  });
}
