import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_date_format.dart';

class ReportExcelEncoder {
  static const transactionsSheet = 'Transactions';
  static const cyclesSheet = 'Cycles';
  static const budgetsSheet = 'Budgets';
  static const recoverablesSheet = 'Recoverables';

  static List<String> sheetNames(ReportSnapshot snapshot) {
    return [
      transactionsSheet,
      cyclesSheet,
      budgetsSheet,
      recoverablesSheet,
    ];
  }

  static Uint8List encode(ReportSnapshot snapshot) {
    final workbook = Excel.createExcel();
    workbook.delete('Sheet1');
    _writeTransactions(workbook, snapshot.cardTransactions);
    _writeCycles(workbook, snapshot.billingCycles);
    _writeBudgets(workbook, snapshot);
    _writeRecoverables(workbook, snapshot.recoverablesByPerson);
    return Uint8List.fromList(workbook.encode()!);
  }

  static void _writeTransactions(
    Excel workbook,
    List<ReportCardTransactionRow> rows,
  ) {
    final sheet = workbook[transactionsSheet];
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('card_nickname'),
      TextCellValue('kind'),
      TextCellValue('amount_paise'),
      TextCellValue('merchant'),
      TextCellValue('transaction_at'),
      TextCellValue('category'),
      TextCellValue('recoverable_person'),
    ]);
    for (final row in rows) {
      sheet.appendRow([
        IntCellValue(row.id),
        TextCellValue(row.cardNickname),
        TextCellValue(row.kind),
        IntCellValue(row.amountPaise),
        TextCellValue(row.merchant),
        TextCellValue(formatReportDateTime(row.transactionAt)),
        TextCellValue(row.category ?? ''),
        TextCellValue(row.recoverablePerson ?? ''),
      ]);
    }
  }

  static void _writeCycles(Excel workbook, List<ReportBillingCycleRow> rows) {
    final sheet = workbook[cyclesSheet];
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('card_nickname'),
      TextCellValue('start_date'),
      TextCellValue('end_date'),
      TextCellValue('bill_generated'),
      TextCellValue('due_date'),
      TextCellValue('payments_applied_paise'),
    ]);
    for (final row in rows) {
      sheet.appendRow([
        IntCellValue(row.id),
        TextCellValue(row.cardNickname),
        TextCellValue(formatReportDate(row.startDate)),
        TextCellValue(formatReportDate(row.endDate)),
        TextCellValue('${row.billGenerated}'),
        TextCellValue(
          row.dueDate == null ? '' : formatReportDate(row.dueDate!),
        ),
        IntCellValue(row.paymentsAppliedPaise),
      ]);
    }
  }

  static void _writeBudgets(Excel workbook, ReportSnapshot snapshot) {
    final sheet = workbook[budgetsSheet];
    sheet.appendRow([
      TextCellValue('section'),
      TextCellValue('name'),
      TextCellValue('limit_paise'),
      TextCellValue('spent_paise'),
      TextCellValue('remaining_paise'),
    ]);

    final monthly = snapshot.monthlyBudget;
    if (monthly != null) {
      sheet.appendRow([
        TextCellValue('monthly'),
        TextCellValue('Monthly budget'),
        IntCellValue(monthly.limitPaise),
        IntCellValue(monthly.spentPaise),
        IntCellValue(monthly.remainingPaise),
      ]);
    }

    for (final row in snapshot.categoryBudgets) {
      sheet.appendRow([
        TextCellValue('category'),
        TextCellValue(row.category),
        IntCellValue(row.limitPaise),
        TextCellValue(''),
        TextCellValue(''),
      ]);
    }
  }

  static void _writeRecoverables(
    Excel workbook,
    Map<String, int> recoverablesByPerson,
  ) {
    final sheet = workbook[recoverablesSheet];
    sheet.appendRow([
      TextCellValue('person'),
      TextCellValue('unsettled_paise'),
    ]);
    for (final entry in recoverablesByPerson.entries) {
      sheet.appendRow([
        TextCellValue(entry.key),
        IntCellValue(entry.value),
      ]);
    }
  }
}
