import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_excel_encoder.dart';

void main() {
  group('ReportExcelEncoder', () {
    test('creates sheets for transactions, cycles, budgets, and recoverables', () {
      final at = DateTime(2026, 7, 9);
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
            referenceNumber: null,
            category: 'Food',
            isRecoverable: false,
            recoverablePerson: null,
            isReviewed: false,
            notes: null,
            location: null,
            createdAt: at,
          ),
        ],
        billingCycles: [
          ReportBillingCycleRow(
            id: 3,
            creditCardId: 2,
            cardNickname: 'HDFC ••5534',
            startDate: DateTime(2026, 6, 16),
            endDate: DateTime(2026, 7, 15),
            billGenerated: false,
            dueDate: null,
            paymentsAppliedPaise: 0,
          ),
        ],
        categories: const ['Food'],
        accounts: const [],
        monthlyBudget: ReportMonthlyBudgetRow(
          limitPaise: 100000,
          spentPaise: 50000,
          remainingPaise: 50000,
          periodStart: DateTime(2026, 7, 1),
          periodEnd: DateTime(2026, 7, 31),
        ),
        categoryBudgets: const [
          ReportCategoryBudgetRow(category: 'Food', limitPaise: 20000),
        ],
        bills: const [],
        analytics: null,
        recoverablesByPerson: const {'Alex Kumar': 50000},
      );

      final bytes = ReportExcelEncoder.encode(snapshot);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes), contains('xl/'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Summary'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Budget'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Card Transactions'));
      expect(ReportExcelEncoder.sheetNames(snapshot), isNot(contains('Bank Transactions')));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Cycles'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Recoverables'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Accounts'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Bills'));
      expect(ReportExcelEncoder.sheetNames(snapshot), contains('Categories'));
    });
  });
}
