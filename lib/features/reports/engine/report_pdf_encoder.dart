import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_date_format.dart';

String reportPdfAmount(int paise) {
  return formatPaise(paise).replaceFirst('₹', 'Rs ');
}

class ReportPdfEncoder {
  static Future<Uint8List> encode(ReportSnapshot snapshot) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('SpendSense Report')),
          pw.Text('Exported ${formatReportDateTime(snapshot.exportedAt)}'),
          pw.SizedBox(height: 12),
          _sectionTitle('Summary'),
          pw.Bullet(
            text:
                'Card transactions: ${snapshot.cardTransactions.length}',
          ),
          pw.Bullet(
            text: 'Bank transactions: ${snapshot.bankTransactions.length}',
          ),
          pw.Bullet(text: 'Billing cycles: ${snapshot.billingCycles.length}'),
          pw.Bullet(text: 'Categories: ${snapshot.categories.length}'),
          pw.Bullet(text: 'Accounts: ${snapshot.accounts.length}'),
          pw.Bullet(text: 'Unpaid bills: ${snapshot.bills.length}'),
          pw.SizedBox(height: 12),
          _sectionTitle('Budget'),
          if (snapshot.monthlyBudget == null)
            pw.Text('No monthly budget configured')
          else ...[
            pw.Text(
              'Spent ${reportPdfAmount(snapshot.monthlyBudget!.spentPaise)} of '
              '${reportPdfAmount(snapshot.monthlyBudget!.limitPaise)}',
            ),
            pw.Text(
              '${reportPdfAmount(snapshot.monthlyBudget!.remainingPaise)} remaining',
            ),
          ],
          pw.SizedBox(height: 12),
          _sectionTitle('Recoverables by person'),
          if (snapshot.recoverablesByPerson.isEmpty)
            pw.Text('No outstanding recoverables')
          else
            pw.Table.fromTextArray(
              headers: const ['Person', 'Unsettled'],
              data: [
                for (final entry in snapshot.recoverablesByPerson.entries)
                  [entry.key, reportPdfAmount(entry.value)],
              ],
            ),
          pw.SizedBox(height: 12),
          _sectionTitle('Recent card transactions'),
          if (snapshot.cardTransactions.isEmpty)
            pw.Text('No card transactions')
          else
            pw.Table.fromTextArray(
              headers: const ['Merchant', 'Amount', 'Card', 'Date'],
              data: [
                for (final row in snapshot.cardTransactions.take(20))
                  [
                    row.merchant,
                    reportPdfAmount(row.amountPaise),
                    row.cardNickname,
                    formatReportDate(row.transactionAt),
                  ],
              ],
            ),
        ],
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 16)),
    );
  }
}
