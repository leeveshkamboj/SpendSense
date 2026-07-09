import 'package:spendsense/core/database/database.dart';

class BankTransactionMonthGroup {
  const BankTransactionMonthGroup({
    required this.header,
    required this.transactions,
  });

  final String header;
  final List<BankAccountTransaction> transactions;
}

List<BankTransactionMonthGroup> groupBankTransactionsByMonth({
  required List<BankAccountTransaction> transactions,
  required DateTime now,
}) {
  final sorted = [...transactions]
    ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

  final grouped = <String, List<BankAccountTransaction>>{};
  for (final transaction in sorted) {
    final header = _monthHeader(transaction.transactionAt, now);
    grouped.putIfAbsent(header, () => []).add(transaction);
  }

  final orderedHeaders = _orderedHeaders(grouped.keys.toList(), now);
  return [
    for (final header in orderedHeaders)
      BankTransactionMonthGroup(
        header: header,
        transactions: grouped[header]!,
      ),
  ];
}

String _monthHeader(DateTime date, DateTime now) {
  if (date.year == now.year && date.month == now.month) {
    return 'This Month';
  }
  if (date.year == now.year && date.month == now.month - 1) {
    return 'Last Month';
  }
  if (date.year == now.year && now.month == 1 && date.month == 12) {
    return 'Last Month';
  }

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

List<String> _orderedHeaders(List<String> headers, DateTime now) {
  int rank(String header) {
    if (header == 'This Month') return 0;
    if (header == 'Last Month') return 1;
    return 2;
  }

  headers.sort((a, b) {
    final rankCompare = rank(a).compareTo(rank(b));
    if (rankCompare != 0) return rankCompare;
    return b.compareTo(a);
  });
  return headers;
}
