import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

void main() {
  group('filterCardTransactions', () {
    test('filters by merchant and reference', () {
      final results = filterCardTransactions(
        transactions: [
          _tx(id: 1, merchant: 'ZOMATO LTD', reference: 'UPI111'),
          _tx(id: 2, merchant: 'SWIGGY', reference: 'UPI222'),
        ],
        query: 'upi111',
      );

      expect(results, hasLength(1));
      expect(results.single.id, 1);
    });
  });
}

CardTransaction _tx({
  required int id,
  required String merchant,
  String? reference,
}) {
  return CardTransaction(
    id: id,
    creditCardId: 1,
    billingCycleId: 1,
    kind: 'expense',
    amountPaise: 10000,
    merchant: merchant,
    transactionAt: DateTime(2026, 7, 9),
    source: 'SMS',
    rawSms: null,
    referenceNumber: reference,
    category: 'Food',
    isRecoverable: false,
    recoverablePerson: null,
    isReviewed: false,
    notes: null,
    location: null,
    createdAt: DateTime(2026, 7, 9),
  );
}
