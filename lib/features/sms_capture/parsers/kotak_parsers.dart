import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

final _kotakCardPattern = RegExp(
  r'Rs\.?([\d.]+)\s+spent\s+on\s+Kotak\s+Credit\s+Card\s+ending\s+(\d{4})\s+at\s+(.+?)(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

final _kotakDebitPattern = RegExp(
  r'Kotak\s+Bank\s+A/?c\s+XX(\d{4})\s+debited\s+by\s+Rs\.?([\d.]+)(?:\s+on\s+([\d-]+))?(?:\s+UPI-(\w+))?',
  caseSensitive: false,
);

ParsedCardExpense? parseKotakCardExpenseSms(String sms) {
  final normalized = normalizeSms(sms);
  final match = _kotakCardPattern.firstMatch(normalized);
  if (match == null) return null;

  return ParsedCardExpense(
    amountPaise: rupeesToPaise(match.group(1)!),
    bank: 'Kotak',
    lastFourDigits: match.group(2)!,
    merchant: match.group(3)!.trim(),
    transactionAt: parseSmsDate(match.group(4)) ?? DateTime.now(),
    rawSms: sms,
  );
}

ParsedBankTransaction? parseKotakBankSms(String sms) {
  final normalized = normalizeSms(sms);
  final match = _kotakDebitPattern.firstMatch(normalized);
  if (match == null) return null;

  return ParsedBankTransaction(
    bank: 'Kotak',
    lastFourDigits: match.group(1)!,
    kind: BankTransactionKind.debit,
    amountPaise: rupeesToPaise(match.group(2)!),
    transactionAt: parseSmsDate(match.group(3)) ?? DateTime.now(),
    rawSms: sms,
    referenceNumber: match.group(4),
  );
}
