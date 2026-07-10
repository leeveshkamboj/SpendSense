import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_pdf_encoder.dart';

void main() {
  group('ReportPdfEncoder', () {
    test('creates formatted summary sections', () async {
      final snapshot = ReportSnapshot(
        exportedAt: DateTime(2026, 7, 10),
        cardTransactions: const [],
        billingCycles: const [],
        categories: const ['Food'],
        accounts: const [],
        monthlyBudget: ReportMonthlyBudgetRow(
          limitPaise: 100000,
          spentPaise: 50000,
          remainingPaise: 50000,
          periodStart: DateTime(2026, 7, 1),
          periodEnd: DateTime(2026, 7, 31),
        ),
        categoryBudgets: const [],
        bills: const [],
        analytics: null,
        recoverablesByPerson: const {'Alex Kumar': 50000},
      );

      final bytes = await ReportPdfEncoder.encode(snapshot);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
