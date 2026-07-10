import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_snapshot_sections.dart';

class ReportExcelEncoder {
  static const summarySheet = 'Summary';
  static const budgetsSheet = 'Budget';
  static const recoverablesSheet = 'Recoverables';
  static const cardTransactionsSheet = 'Card Transactions';
  static const cyclesSheet = 'Cycles';
  static const accountsSheet = 'Accounts';
  static const billsSheet = 'Bills';
  static const categoriesSheet = 'Categories';

  static List<String> sheetNames(ReportSnapshot snapshot) {
    return [
      summarySheet,
      budgetsSheet,
      recoverablesSheet,
      cardTransactionsSheet,
      cyclesSheet,
      accountsSheet,
      billsSheet,
      categoriesSheet,
    ];
  }

  static Uint8List encode(ReportSnapshot snapshot) {
    final workbook = Excel.createExcel();
    workbook.delete('Sheet1');
    _writeTable(workbook, summarySheet, ReportSnapshotSections.summaryTable(snapshot));
    _writeTable(workbook, budgetsSheet, ReportSnapshotSections.budgetTable(snapshot));
    _writeTable(
      workbook,
      recoverablesSheet,
      ReportSnapshotSections.recoverablesTable(snapshot.recoverablesByPerson),
    );
    _writeTable(
      workbook,
      cardTransactionsSheet,
      ReportSnapshotSections.cardTransactionsTable(snapshot.cardTransactions),
    );
    _writeTable(
      workbook,
      cyclesSheet,
      ReportSnapshotSections.billingCyclesTable(snapshot.billingCycles),
    );
    _writeTable(
      workbook,
      accountsSheet,
      ReportSnapshotSections.accountsTable(snapshot.accounts),
    );
    _writeTable(
      workbook,
      billsSheet,
      ReportSnapshotSections.billsTable(snapshot.bills),
    );
    _writeTable(
      workbook,
      categoriesSheet,
      ReportSnapshotSections.categoriesTable(snapshot.categories),
    );
    return Uint8List.fromList(workbook.encode()!);
  }

  static void _writeTable(
    Excel workbook,
    String sheetName,
    List<List<dynamic>> rows,
  ) {
    final sheet = workbook[sheetName];
    for (final row in rows) {
      sheet.appendRow([
        for (final value in row) _cellValue(value),
      ]);
    }
  }

  static CellValue _cellValue(dynamic value) {
    return switch (value) {
      null => TextCellValue(''),
      int() => IntCellValue(value),
      bool() => TextCellValue('$value'),
      _ => TextCellValue('$value'),
    };
  }
}
