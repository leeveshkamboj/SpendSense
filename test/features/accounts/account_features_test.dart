import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/domain/account_balance.dart';
import 'package:spendsense/features/transactions/domain/grouped_bank_transactions.dart';

void main() {
  group('Account balance', () {
    test('computes balance from opening balance plus credits minus debits', () {
      final balance = computeAccountBalance(
        openingBalancePaise: 100000,
        transactions: [
          BankAccountTransaction(
            id: 1,
            bankAccountId: 1,
            kind: 'credit',
            amountPaise: 50000,
            merchant: null,
            beneficiary: null,
            category: 'Salary',
            transactionAt: DateTime(2026, 7, 1),
            source: 'SMS',
            rawSms: null,
            referenceNumber: null,
            isReviewed: true,
            isRecurring: false,
            notes: null,
            location: null,
            createdAt: DateTime(2026, 7, 1),
          ),
          BankAccountTransaction(
            id: 2,
            bankAccountId: 1,
            kind: 'debit',
            amountPaise: 20000,
            merchant: null,
            beneficiary: 'MERCHANT',
            category: null,
            transactionAt: DateTime(2026, 7, 2),
            source: 'SMS',
            rawSms: null,
            referenceNumber: null,
            isReviewed: true,
            isRecurring: false,
            notes: null,
            location: null,
            createdAt: DateTime(2026, 7, 2),
          ),
        ],
      );

      expect(balance, 130000);
    });
  });

  group('Grouped bank transactions', () {
    test('groups by This Month, Last Month, and month-year', () {
      final now = DateTime(2026, 7, 15);
      final groups = groupBankTransactionsByMonth(
        transactions: [
          _tx(id: 1, at: DateTime(2026, 7, 10)),
          _tx(id: 2, at: DateTime(2026, 6, 20)),
          _tx(id: 3, at: DateTime(2025, 12, 5)),
        ],
        now: now,
      );

      expect(groups.map((g) => g.header), [
        'This Month',
        'Last Month',
        'December 2025',
      ]);
    });
  });
}

BankAccountTransaction _tx({required int id, required DateTime at}) {
  return BankAccountTransaction(
    id: id,
    bankAccountId: 1,
    kind: 'debit',
    amountPaise: 10000,
    merchant: null,
    beneficiary: 'Shop',
    category: null,
    transactionAt: at,
    source: 'SMS',
    rawSms: null,
    referenceNumber: null,
    isReviewed: false,
    isRecurring: false,
    notes: null,
    location: null,
    createdAt: at,
  );
}
