import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/transactions/domain/grouped_card_transactions.dart';

void main() {
  group('Grouped card transactions', () {
    test('groups transactions under their billing cycle', () {
      final groups = groupCardTransactionsByCycle(
        transactions: [
          CardTransaction(
            id: 1,
            creditCardId: 1,
            billingCycleId: 10,
            kind: 'expense',
            amountPaise: 41167,
            merchant: 'ZOMATO LTD',
            transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
            source: 'SMS',
            rawSms: 'sms',
            referenceNumber: null,
            category: null,
            isRecoverable: false,
            recoverablePerson: null,
            isReviewed: false,
    isRecurring: false,
            createdAt: DateTime(2026, 7, 9, 16, 16),
          ),
        ],
        cyclesById: {
          10: BillingCycle(
            id: 10,
            creditCardId: 1,
            startDate: DateTime(2026, 6, 16),
            endDate: DateTime(2026, 7, 15),
            billGenerated: true,
            dueDate: DateTime(2026, 8, 2),
            paymentsAppliedPaise: 0,
          ),
        },
        nicknameByCardId: const {1: 'HDFC ••5534'},
        currentCycleIds: const {10},
      );

      expect(groups.length, 1);
      expect(groups.first.cycleLabel, contains('16/06/2026'));
      expect(groups.first.transactions.single.merchant, 'ZOMATO LTD');
    });
  });
}
