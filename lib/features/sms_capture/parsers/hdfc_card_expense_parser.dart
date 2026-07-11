import 'package:spendsense/core/formatting/merchant_display.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

final _spentPattern = RegExp(
  r'Spent Rs\.?([\d,]+(?:\.\d+)?) On HDFC Bank Card x?(\d{4}) At (.+?) On '
  r'(\d{4})-(\d{2})-(\d{2}):(\d{2}):(\d{2}):(\d{2})',
  caseSensitive: false,
);

/// Newer HDFC wording: amount first, optional masked "x" before last-4.
final _rsSpentOnPattern = RegExp(
  r'Rs\.?([\d,]+(?:\.\d+)?) spent on HDFC Bank Card x?(\d{4}) at (.+?) on '
  r'(\d{4})-(\d{2})-(\d{2}):(\d{2}):(\d{2}):(\d{2})',
  caseSensitive: false,
);

final _txnPattern = RegExp(
  r'Txn Rs\.?([\d,]+(?:\.\d+)?) On HDFC Bank Card x?(\d{4}) At (.+?)(?=\s+by UPI(?:\s+\d+)?|\s+On\s+[\d-]+|$)',
  caseSensitive: false,
);

/// Parses HDFC credit card expense SMS in supported formats.
ParsedCardExpense? parseHdfcCardExpenseSms(String sms) {
  final normalized = sms.replaceAll(RegExp(r'\s+'), ' ').trim();

  final spentMatch =
      _spentPattern.firstMatch(normalized) ??
      _rsSpentOnPattern.firstMatch(normalized);
  if (spentMatch != null) {
    return ParsedCardExpense(
      amountPaise: rupeesToPaise(spentMatch.group(1)!),
      bank: 'HDFC',
      lastFourDigits: spentMatch.group(2)!,
      merchant: cleanParsedMerchant(spentMatch.group(3)!),
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
      amountPaise: rupeesToPaise(txnMatch.group(1)!),
      bank: 'HDFC',
      lastFourDigits: txnMatch.group(2)!,
      merchant: cleanParsedMerchant(txnMatch.group(3)!),
      transactionAt: parseSmsDateFromSuffix(normalized) ?? DateTime.now(),
      rawSms: sms,
    );
  }

  return null;
}
