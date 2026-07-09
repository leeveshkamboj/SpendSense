import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/transactions/engine/transaction_merge.dart';
import 'package:spendsense/features/transactions/engine/transaction_search.dart';

void main() {
  group('Transaction search', () {
    test('matches merchant and reference number', () {
      expect(
        matchesCardTransactionSearch(
          merchant: 'ZOMATO LTD',
          category: 'Food',
          referenceNumber: 'UPI123',
          notes: null,
          query: 'upi123',
        ),
        isTrue,
      );
      expect(
        matchesCardTransactionSearch(
          merchant: 'ZOMATO LTD',
          category: 'Food',
          referenceNumber: 'UPI123',
          notes: null,
          query: 'swiggy',
        ),
        isFalse,
      );
    });

    test('matches bank beneficiary', () {
      expect(
        matchesBankTransactionSearch(
          merchant: null,
          beneficiary: 'MERCHANT',
          category: 'Shopping',
          referenceNumber: null,
          notes: null,
          query: 'merchant',
        ),
        isTrue,
      );
    });
  });

  group('Transaction merge', () {
    test('sums amounts and merges notes', () {
      expect(
        mergedAmountPaise(
          survivorAmountPaise: 50000,
          duplicateAmountPaise: 25000,
        ),
        75000,
      );
      expect(
        mergedNotes(
          survivorNotes: 'First',
          duplicateNotes: 'Second',
        ),
        'First\nSecond',
      );
    });
  });
}
