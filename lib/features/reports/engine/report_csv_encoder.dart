import 'package:csv/csv.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_snapshot_sections.dart';

class ReportCsvEncoder {
  static String encode(ReportSnapshot snapshot) {
    final sections = <String>[
      _section('Summary', ReportSnapshotSections.summaryTable(snapshot)),
      _section('Budget', ReportSnapshotSections.budgetTable(snapshot)),
      _section(
        'Recoverables by person',
        ReportSnapshotSections.recoverablesTable(snapshot.recoverablesByPerson),
      ),
      _section(
        'Card transactions',
        ReportSnapshotSections.cardTransactionsTable(snapshot.cardTransactions),
      ),
      _section(
        'Billing cycles',
        ReportSnapshotSections.billingCyclesTable(snapshot.billingCycles),
      ),
      _section('Accounts', ReportSnapshotSections.accountsTable(snapshot.accounts)),
      _section('Unpaid bills', ReportSnapshotSections.billsTable(snapshot.bills)),
      _section(
        'Categories',
        ReportSnapshotSections.categoriesTable(snapshot.categories),
      ),
    ];
    return sections.join('\n\n');
  }

  static String _section(String title, List<List<dynamic>> rows) {
    return '$title\n${csv.encode(rows)}';
  }
}
