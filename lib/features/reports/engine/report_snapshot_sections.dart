import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_date_format.dart';
import 'package:spendsense/features/reports/engine/report_transaction_display.dart';

String reportExportAmount(int paise) {
  return formatPaise(paise);
}

String reportRecoverableLabel(ReportCardTransactionRow row) {
  if (!row.isRecoverable) {
    return 'No';
  }
  return row.recoverablePerson ?? 'Yes';
}

class ReportSnapshotSections {
  static List<List<dynamic>> summaryTable(ReportSnapshot snapshot) {
    return [
      ['metric', 'value'],
      ['exported_at', formatReportDateTime(snapshot.exportedAt)],
      ['card_transactions', snapshot.cardTransactions.length],
      ['billing_cycles', snapshot.billingCycles.length],
      ['categories', snapshot.categories.length],
      ['accounts', snapshot.accounts.length],
      ['unpaid_bills', snapshot.bills.length],
    ];
  }

  static List<List<dynamic>> budgetTable(ReportSnapshot snapshot) {
    final rows = <List<dynamic>>[
      ['section', 'name', 'limit_paise', 'spent_paise', 'remaining_paise'],
    ];

    final monthly = snapshot.monthlyBudget;
    if (monthly == null) {
      rows.add(['monthly', 'Not configured', '', '', '']);
    } else {
      rows.add([
        'monthly',
        'Monthly budget',
        monthly.limitPaise,
        monthly.spentPaise,
        monthly.remainingPaise,
      ]);
    }

    for (final budget in snapshot.categoryBudgets) {
      rows.add([
        'category',
        budget.category,
        budget.limitPaise,
        '',
        '',
      ]);
    }

    return rows;
  }

  static List<List<dynamic>> recoverablesTable(
    Map<String, int> recoverablesByPerson,
  ) {
    return [
      ['person', 'unsettled_paise'],
      for (final entry in recoverablesByPerson.entries)
        [entry.key, entry.value],
    ];
  }

  static List<List<dynamic>> cardTransactionsTable(
    List<ReportCardTransactionRow> rows,
  ) {
    return [
      [
        'transaction_at',
        'card_nickname',
        'merchant',
        'kind',
        'direction',
        'amount_paise',
        'amount',
        'signed_amount',
        'category',
        'source',
        'reference_number',
        'recoverable',
        'notes',
        'id',
        'credit_card_id',
        'billing_cycle_id',
        'is_reviewed',
        'location',
        'created_at',
      ],
      for (final row in rows)
        () {
          final direction = reportCardDirectionLabel(row.kind);
          return [
            formatReportDateTime(row.transactionAt),
            row.cardNickname,
            row.merchant,
            row.kind,
            direction,
            row.amountPaise,
            reportExportAmount(row.amountPaise),
            reportSignedAmount(row.amountPaise, direction),
            row.category,
            row.source,
            row.referenceNumber,
            reportRecoverableLabel(row),
            row.notes,
            row.id,
            row.creditCardId,
            row.billingCycleId,
            row.isReviewed,
            row.location,
            formatReportDateTime(row.createdAt),
          ];
        }(),
    ];
  }

  static List<List<dynamic>> billingCyclesTable(
    List<ReportBillingCycleRow> rows,
  ) {
    return [
      [
        'id',
        'credit_card_id',
        'card_nickname',
        'start_date',
        'end_date',
        'bill_generated',
        'due_date',
        'payments_applied_paise',
      ],
      for (final row in rows)
        [
          row.id,
          row.creditCardId,
          row.cardNickname,
          formatReportDate(row.startDate),
          formatReportDate(row.endDate),
          row.billGenerated,
          row.dueDate == null ? null : formatReportDate(row.dueDate!),
          row.paymentsAppliedPaise,
        ],
    ];
  }

  static List<List<dynamic>> accountsTable(List<ReportAccountRow> rows) {
    return [
      ['id', 'kind', 'bank', 'nickname', 'last_four_digits', 'is_archived'],
      for (final row in rows)
        [
          row.id,
          row.kind,
          row.bank,
          row.nickname,
          row.lastFourDigits,
          row.isArchived,
        ],
    ];
  }

  static List<List<dynamic>> billsTable(List<ReportBillRow> rows) {
    return [
      [
        'cycle_id',
        'card_nickname',
        'due_date',
        'total_outstanding_paise',
        'net_outstanding_paise',
        'status',
      ],
      for (final row in rows)
        [
          row.cycleId,
          row.cardNickname,
          row.dueDate == null ? null : formatReportDate(row.dueDate!),
          row.totalOutstandingPaise,
          row.netOutstandingPaise,
          row.status,
        ],
    ];
  }

  static List<List<dynamic>> categoriesTable(List<String> categories) {
    return [
      ['category'],
      for (final category in categories) [category],
    ];
  }
}
