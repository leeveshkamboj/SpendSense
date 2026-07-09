import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';

final _spentPattern = RegExp(
  r'Spent Rs\.?(\d+(?:\.\d+)?) On HDFC Bank Card (\d{4}) At (.+?) On '
  r'(\d{4})-(\d{2})-(\d{2}):(\d{2}):(\d{2}):(\d{2})',
  caseSensitive: false,
);

final _txnPattern = RegExp(
  r'Txn Rs\.?(\d+(?:\.\d+)?) On HDFC Bank Card (\d{4}) At (.+?)(?: by UPI)?\.?$',
  caseSensitive: false,
);

/// Parses HDFC credit card expense SMS in supported formats.
ParsedCardExpense? parseHdfcCardExpenseSms(String sms) {
  final normalized = sms.replaceAll(RegExp(r'\s+'), ' ').trim();

  final spentMatch = _spentPattern.firstMatch(normalized);
  if (spentMatch != null) {
    return ParsedCardExpense(
      amountPaise: _rupeesToPaise(spentMatch.group(1)!),
      bank: 'HDFC',
      lastFourDigits: spentMatch.group(2)!,
      merchant: spentMatch.group(3)!.trim(),
      transactionAt: DateTime(
        int.parse(spentMatch.group(4)!),
        int.parse(spentMatch.group(5)!),
        int.parse(spentMatch.group(6)!),
        int.parse(spentMatch.group(7)!),
        int.parse(spentMatch.group(8)!),
        int.parse(spentMatch.group(9)!),
      ),
      rawSms: sms,
    );
  }

  final txnMatch = _txnPattern.firstMatch(normalized);
  if (txnMatch != null) {
    return ParsedCardExpense(
      amountPaise: _rupeesToPaise(txnMatch.group(1)!),
      bank: 'HDFC',
      lastFourDigits: txnMatch.group(2)!,
      merchant: txnMatch.group(3)!.trim(),
      transactionAt: DateTime.now(),
      rawSms: sms,
    );
  }

  return null;
}

int _rupeesToPaise(String rupees) {
  final value = double.parse(rupees);
  return (value * 100).round();
}
