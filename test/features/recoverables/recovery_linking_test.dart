import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/recoverables/domain/recoverable_expense.dart';
import 'package:spendsense/features/recoverables/domain/recovery_link.dart';
import 'package:spendsense/features/recoverables/engine/recovery_linking.dart';

void main() {
  group('Recovery linking', () {
    const expense = RecoverableExpense(
      transactionId: 1,
      person: 'Rahul',
      amountPaise: 10000,
    );

    test('rejects recovery link above unsettled recoverable amount', () {
      expect(
        () => validateRecoveryLink(
          expense: expense,
          existingRecoveries: const [],
          newLinkAmountPaise: 12000,
        ),
        throwsArgumentError,
      );
    });

    test('allows partial recovery across multiple links', () {
      expect(
        validateRecoveryLink(
          expense: expense,
          existingRecoveries: const [
            RecoveryAllocation(
              creditTransactionId: 50,
              recoverableTransactionId: 1,
              amountPaise: 4000,
            ),
          ],
          newLinkAmountPaise: 3000,
        ),
        isTrue,
      );
    });
  });
}
