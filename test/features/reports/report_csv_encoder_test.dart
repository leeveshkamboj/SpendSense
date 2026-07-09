import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_csv_encoder.dart';

void main() {
  group('ReportCsvEncoder', () {
    test('includes card transaction rows with all fields', () {
      final at = DateTime(2026, 7, 9, 14, 30);
      final createdAt = DateTime(2026, 7, 9, 14, 31);
      final snapshot = ReportSnapshot(
        exportedAt: DateTime(2026, 7, 10),
        cardTransactions: [
          ReportCardTransactionRow(
            id: 1,
            creditCardId: 2,
            cardNickname: 'HDFC ••5534',
            billingCycleId: 3,
            kind: 'expense',
            amountPaise: 50000,
            merchant: 'ZOMATO LTD',
            transactionAt: at,
            source: 'SMS',
            referenceNumber: 'REF123',
            category: 'Food',
            isRecoverable: true,
            recoverablePerson: 'Alex Kumar',
            isReviewed: false,
            notes: 'Team lunch',
            location: 'Bangalore',
            createdAt: createdAt,
          ),
        ],
        bankTransactions: const [],
        billingCycles: const [],
        categories: const [],
        accounts: const [],
        monthlyBudget: null,
        categoryBudgets: const [],
        bills: const [],
        analytics: null,
        recoverablesByPerson: const {},
      );

      final csv = ReportCsvEncoder.encode(snapshot);

      expect(csv, contains('id,credit_card_id,card_nickname,billing_cycle_id,kind'));
      expect(csv, contains('ZOMATO LTD'));
      expect(csv, contains('Alex Kumar'));
      expect(csv, contains('REF123'));
      expect(csv, contains('Team lunch'));
    });

    test('includes recoverable breakdown by person with full names', () {
      final snapshot = ReportSnapshot(
        exportedAt: DateTime(2026, 7, 10),
        cardTransactions: const [],
        bankTransactions: const [],
        billingCycles: const [],
        categories: const [],
        accounts: const [],
        monthlyBudget: null,
        categoryBudgets: const [],
        bills: const [],
        analytics: null,
        recoverablesByPerson: const {'Alex Kumar': 50000},
      );

      final csv = ReportCsvEncoder.encode(snapshot);

      expect(csv, contains('person,unsettled_paise'));
      expect(csv, contains('Alex Kumar'));
      expect(csv, contains('50000'));
    });
  });
}
