import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';
import 'package:spendsense/features/sms_capture/parsers/sbi_parsers.dart';

final _axisCardPattern = RegExp(
  r'INR\s+([\d.]+)\s+spent\s+on\s+Axis\s+Bank\s+Card\s+XX(\d{4})\s+at\s+(.+?)(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

final _axisCreditPattern = RegExp(
  r'Axis\s+Bank\s+A/?c\s+XX(\d{4})\s+credited\s+with\s+INR\s+([\d.]+)(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

ParsedCardExpense? parseAxisCardExpenseSms(String sms) {
  final normalized = normalizeSms(sms);
  final match = _axisCardPattern.firstMatch(normalized);
  if (match == null) return null;

  return ParsedCardExpense(
    amountPaise: rupeesToPaise(match.group(1)!),
    bank: 'Axis',
    lastFourDigits: match.group(2)!,
    merchant: match.group(3)!.trim(),
    transactionAt: parseSmsDate(match.group(4)) ?? DateTime.now(),
    rawSms: sms,
  );
}

ParsedBankTransaction? parseAxisBankSms(String sms) {
  final normalized = normalizeSms(sms);
  final match = _axisCreditPattern.firstMatch(normalized);
  if (match == null) return null;

  return ParsedBankTransaction(
    bank: 'Axis',
    lastFourDigits: match.group(1)!,
    kind: BankTransactionKind.credit,
    amountPaise: rupeesToPaise(match.group(2)!),
    transactionAt: parseSmsDate(match.group(3)) ?? DateTime.now(),
    rawSms: sms,
    category: detectBankCreditCategory(sms),
  );
}
