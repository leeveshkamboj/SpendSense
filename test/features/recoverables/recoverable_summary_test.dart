import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/recoverables/domain/recoverable_expense.dart';
import 'package:spendsense/features/recoverables/domain/recovery_link.dart';
import 'package:spendsense/features/recoverables/engine/recoverable_outstanding.dart';

void main() {
  group('Recoverable summary', () {
    test('groups unsettled amounts by person', () {
      final summary = summarizeRecoverablesByPerson(
        expenses: const [
          RecoverableExpense(
            transactionId: 1,
            person: 'Rahul',
            amountPaise: 10000,
          ),
          RecoverableExpense(
            transactionId: 2,
            person: 'Rahul',
            amountPaise: 5000,
          ),
          RecoverableExpense(
            transactionId: 3,
            person: 'Priya',
            amountPaise: 8000,
          ),
        ],
        recoveries: const [
          RecoveryAllocation(
            creditTransactionId: 99,
            recoverableTransactionId: 1,
            amountPaise: 10000,
          ),
        ],
      );

      expect(summary['Rahul'], 5000);
      expect(summary['Priya'], 8000);
    });
  });
}
