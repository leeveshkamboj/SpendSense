import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

final _sbiMandatePattern = RegExp(
  r'Trxn\.?\s+of\s+Rs\.?([\d.]+)\s+at\s+(.+?)\s+on\s+SBI\s+Card\s+(\d{4})(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

final _sbiCardUpiPattern = RegExp(
  r'Rs\.?([\d.]+)\s+spent\s+on\s+your\s+SBI\s+Credit\s+Card\s+ending\s+with\s+(\d{4})\s+at\s+(.+?)\s+on\s+([\d-]+)(?:\s+Ref\s+(\w+))?',
  caseSensitive: false,
);

final _sbiDebitPattern = RegExp(
  r'A/?C\s+X?(\d{4})\s+debited\s+by\s+([\d.]+)\s+on\s+([\d-]+)\s+to\s+(.+?)(?:\s+Ref\s+(\w+))?$',
  caseSensitive: false,
);

final _sbiCreditPattern = RegExp(
  r'A/?c\s+X?(\d{4})\s+credited\s+by\s+Rs\.?([\d.]+)(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

ParsedCardExpense? parseSbiCardExpenseSms(String sms) {
  final normalized = normalizeSms(sms);

  final mandate = _sbiMandatePattern.firstMatch(normalized);
  if (mandate != null) {
    return ParsedCardExpense(
      amountPaise: rupeesToPaise(mandate.group(1)!),
      bank: 'SBI',
      lastFourDigits: mandate.group(3)!,
      merchant: mandate.group(2)!.trim(),
      transactionAt: parseSmsDate(mandate.group(4)) ?? DateTime.now(),
      rawSms: sms,
    );
  }

  final upi = _sbiCardUpiPattern.firstMatch(normalized);
  if (upi != null) {
    return ParsedCardExpense(
      amountPaise: rupeesToPaise(upi.group(1)!),
      bank: 'SBI',
      lastFourDigits: upi.group(2)!,
      merchant: upi.group(3)!.trim(),
      transactionAt: parseSmsDate(upi.group(4)) ?? DateTime.now(),
      rawSms: sms,
      referenceNumber: upi.group(5),
    );
  }

  return null;
}

ParsedBankTransaction? parseSbiBankSms(String sms) {
  final normalized = normalizeSms(sms);

  final debit = _sbiDebitPattern.firstMatch(normalized);
  if (debit != null) {
    return ParsedBankTransaction(
      bank: 'SBI',
      lastFourDigits: debit.group(1)!,
      kind: BankTransactionKind.debit,
      amountPaise: rupeesToPaise(debit.group(2)!),
      beneficiary: debit.group(4)!.trim(),
      transactionAt: parseSmsDate(debit.group(3)) ?? DateTime.now(),
      rawSms: sms,
      referenceNumber: debit.group(5),
    );
  }

  final credit = _sbiCreditPattern.firstMatch(normalized);
  if (credit != null) {
    return ParsedBankTransaction(
      bank: 'SBI',
      lastFourDigits: credit.group(1)!,
      kind: BankTransactionKind.credit,
      amountPaise: rupeesToPaise(credit.group(2)!),
      transactionAt: parseSmsDate(credit.group(3)) ?? DateTime.now(),
      rawSms: sms,
      category: detectBankCreditCategory(sms),
    );
  }

  return null;
}

String? detectBankCreditCategory(String sms) {
  final upper = sms.toUpperCase();
  if (upper.contains('SALARY') || upper.contains('NEFT CR')) {
    return 'Salary';
  }
  if (upper.contains('INTEREST') || upper.contains('INT CR')) {
    return 'Investment';
  }
  return null;
}
