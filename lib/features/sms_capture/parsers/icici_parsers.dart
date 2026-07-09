import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

final _iciciCardPattern = RegExp(
  r'INR\s+([\d,]+(?:\.\d+)?)\s+on\s+ICICI\s+Bank\s+Credit\s+Card\s+XX(\d{4})\s+at\s+(.+?)\s+on\s+([\d-]+)',
  caseSensitive: false,
);

final _iciciDebitPattern = RegExp(
  r'ICICI\s+Bank\s+Acct\s+XX(\d{4})\s+debited\s+for\s+Rs\s+([\d.]+)(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

ParsedCardExpense? parseIciciCardExpenseSms(String sms) {
  final normalized = normalizeSms(sms);
  final match = _iciciCardPattern.firstMatch(normalized);
  if (match == null) return null;

  return ParsedCardExpense(
    amountPaise: rupeesToPaise(match.group(1)!.replaceAll(',', '')),
    bank: 'ICICI',
    lastFourDigits: match.group(2)!,
    merchant: match.group(3)!.trim(),
    transactionAt: parseSmsDate(match.group(4)) ?? DateTime.now(),
    rawSms: sms,
  );
}

ParsedBankTransaction? parseIciciBankSms(String sms) {
  final normalized = normalizeSms(sms);
  final match = _iciciDebitPattern.firstMatch(normalized);
  if (match == null) return null;

  return ParsedBankTransaction(
    bank: 'ICICI',
    lastFourDigits: match.group(1)!,
    kind: BankTransactionKind.debit,
    amountPaise: rupeesToPaise(match.group(2)!),
    transactionAt: parseSmsDate(match.group(3)) ?? DateTime.now(),
    rawSms: sms,
  );
}
