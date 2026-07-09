import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/recoverables/engine/transaction_split.dart';

void main() {
  group('Transaction split', () {
    test('split lines must sum to original amount', () {
      expect(
        () => validateSplitAmounts(
          originalAmountPaise: 10000,
          personalAmountPaise: 6000,
          recoverableAmountPaise: 3000,
        ),
        throwsArgumentError,
      );
    });

    test('accepts valid personal and recoverable split', () {
      expect(
        validateSplitAmounts(
          originalAmountPaise: 10000,
          personalAmountPaise: 6000,
          recoverableAmountPaise: 4000,
        ),
        isTrue,
      );
    });
  });
}
