import 'package:csv/csv.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/engine/report_date_format.dart';

class ReportCsvEncoder {
  static String encode(ReportSnapshot snapshot) {
    final sections = <String>[
      _encodeCardTransactions(snapshot.cardTransactions),
      _encodeRecoverables(snapshot.recoverablesByPerson),
    ];
    return sections.join('\n\n');
  }

  static String _encodeCardTransactions(List<ReportCardTransactionRow> rows) {
    const header = [
      'id',
      'credit_card_id',
      'card_nickname',
      'billing_cycle_id',
      'kind',
      'amount_paise',
      'merchant',
      'transaction_at',
      'source',
      'reference_number',
      'category',
      'is_recoverable',
      'recoverable_person',
      'is_reviewed',
      'notes',
      'location',
      'created_at',
    ];

    final data = [
      header,
      for (final row in rows)
        [
          row.id,
          row.creditCardId,
          row.cardNickname,
          row.billingCycleId,
          row.kind,
          row.amountPaise,
          row.merchant,
          formatReportDateTime(row.transactionAt),
          row.source,
          row.referenceNumber,
          row.category,
          row.isRecoverable,
          row.recoverablePerson,
          row.isReviewed,
          row.notes,
          row.location,
          formatReportDateTime(row.createdAt),
        ],
    ];

    return csv.encode(data);
  }

  static String _encodeRecoverables(Map<String, int> recoverablesByPerson) {
    final data = <List<dynamic>>[
      ['person', 'unsettled_paise'],
      for (final entry in recoverablesByPerson.entries)
        [entry.key, entry.value],
    ];
    return csv.encode(data);
  }
}
