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

    test('filters by card id', () {
      final results = filterCardTransactions(
        transactions: [
          _tx(id: 1, merchant: 'ZOMATO LTD', cardId: 1),
          _tx(id: 2, merchant: 'SWIGGY', cardId: 2),
        ],
        query: '',
        cardId: 2,
      );

      expect(results, hasLength(1));
      expect(results.single.merchant, 'SWIGGY');
    });

    test('keeps unassigned transactions in current cycle view', () {
      final results = filterCardTransactions(
        transactions: [
          _tx(id: 1, merchant: 'ZOMATO LTD', cardId: 1, billingCycleId: 99),
          _tx(id: 2, merchant: 'SWIGGY', cardId: 1, billingCycleId: null),
        ],
        query: '',
        currentCycleOnly: true,
        currentCycleIds: {99},
      );

      expect(results, hasLength(2));
    });
  });
}

CardTransaction _tx({
  required int id,
  required String merchant,
  String? reference,
  int cardId = 1,
  int? billingCycleId = 1,
}) {
  return CardTransaction(
    id: id,
    creditCardId: cardId,
    billingCycleId: billingCycleId,
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
    isRecurring: false,
    notes: null,
    location: null,
    createdAt: DateTime(2026, 7, 9),
  );
}
