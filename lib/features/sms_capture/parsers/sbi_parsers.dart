import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

final _sbiMandatePattern = RegExp(
  r'Trxn\.?\s+of\s+Rs\.?\s*([\d,.]+)\s+at\s+(.+?)\s+on\s+SBI\s+Card\s+(\d{4})(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

final _sbiEMandateDebitPattern = RegExp(
  r'Trxn\.?\s+of\s+Rs\.?\s*([\d,.]+)\s+at\s+(.+?)\s+against\s+e-?Mandate.+?ending\s+(\d{4})',
  caseSensitive: false,
);

final _sbiCardholderTxnPattern = RegExp(
  r'Trxn\.?\s+of\s+Rs\.?\s*([\d,.]+)\s+on\s+your\s+SBI\s+Credit\s+Card\s+ending\s+(\d{4})\s+at\s+(.+?)\s+(?:on|dated)\s+(\d{2}-\d{2}-\d{2})',
  caseSensitive: false,
);

final _sbiCardUpiPattern = RegExp(
  r'Rs\.?\s*([\d,.]+)\s+spent\s+on\s+your\s+SBI\s+Credit\s+Card\s+ending\s+with\s+(\d{4})\s+at\s+(.+?)\s+on\s+([\d-]+)(?:\s+via\s+UPI)?(?:\s*\(Ref\s+No\.?\s+(\w+)\))?(?:\s+Ref\s+(\w+))?',
  caseSensitive: false,
);

final _sbiCardUpiLoosePattern = RegExp(
  r'Rs\.?\s*([\d,.]+).+?with\s+(\d{4})\s+at\s+(.+?)\s+on\s+(\d{2}-\d{2}-\d{2})(?:\s+via\s+UPI)?(?:\s*\(Ref\s+No\.?\s+(\w+)\))?',
  caseSensitive: false,
);

final _sbiCardPaymentDebitPattern = RegExp(
  r'A/?C\s+X?(\d{4})\s+debited\s+by\s+([\d,.]+)\s+on\s+([\d-]+)\s+towards\s+(.+?credit\s+card.+?)(\d{4})',
  caseSensitive: false,
);

final _sbiDebitPattern = RegExp(
  r'A/?C\s+X?(\d{4})\s+debited\s+by\s+([\d,.]+)\s+on\s+([\d-]+)\s+to\s+(.+?)(?:\s+Ref\s+(\w+))?$',
  caseSensitive: false,
);

final _sbiUpiDebitPattern = RegExp(
  r'A/?C\s+X?(\d{4})\s+debited\s+by\s+([\d,.]+)\s+on\s+date\s+(\S+)\s+trf\s+to\s+(.+)\s+Refno\s+(\w+)',
  caseSensitive: false,
);

final _sbiCreditPattern = RegExp(
  r'A/?c\s+X?(\d{4})\s+credited\s+by\s+Rs\.?\s*([\d,.]+)(?:\s+on\s+([\d-]+))?',
  caseSensitive: false,
);

final _sbiHyphenCreditPattern = RegExp(
  r'A/?c\s+X?(\d{4})-credited\s+by\s+Rs\.?\s*([\d,.]+)\s+on\s+(\S+)',
  caseSensitive: false,
);

final _sbiMaskedCreditPattern = RegExp(
  r'a/c\s+no\.?\s+X+(\d{4})\s+is\s+credited\s+by\s+Rs\.?\s*([\d,.]+)\s+on\s+([\d-]+)',
  caseSensitive: false,
);

bool _isDeclinedSbiCardSms(String normalized) {
  return normalized.toLowerCase().contains('declined');
}

ParsedCardExpense? parseSbiCardExpenseSms(String sms) {
  final normalized = normalizeSms(sms);
  if (_isDeclinedSbiCardSms(normalized)) {
    return null;
  }

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

  final eMandate = _sbiEMandateDebitPattern.firstMatch(normalized);
  if (eMandate != null) {
    return ParsedCardExpense(
      amountPaise: rupeesToPaise(eMandate.group(1)!),
      bank: 'SBI',
      lastFourDigits: eMandate.group(3)!,
      merchant: eMandate.group(2)!.trim(),
      transactionAt: parseSmsDateFromSuffix(normalized) ?? DateTime.now(),
      rawSms: sms,
    );
  }

  final cardholderTxn = _sbiCardholderTxnPattern.firstMatch(normalized);
  if (cardholderTxn != null) {
    return ParsedCardExpense(
      amountPaise: rupeesToPaise(cardholderTxn.group(1)!),
      bank: 'SBI',
      lastFourDigits: cardholderTxn.group(2)!,
      merchant: cardholderTxn.group(3)!.trim(),
      transactionAt: parseSmsDate(cardholderTxn.group(4)) ?? DateTime.now(),
      rawSms: sms,
    );
  }

  final upi = _sbiCardUpiPattern.firstMatch(normalized);
  if (upi != null) {
    return _parsedSbiCardUpi(upi, sms);
  }

  final looseUpi = _sbiCardUpiLoosePattern.firstMatch(normalized);
  if (looseUpi != null) {
    return _parsedSbiCardUpi(looseUpi, sms);
  }

  return null;
}

ParsedCardExpense _parsedSbiCardUpi(RegExpMatch match, String rawSms) {
  return ParsedCardExpense(
    amountPaise: rupeesToPaise(match.group(1)!),
    bank: 'SBI',
    lastFourDigits: match.group(2)!,
    merchant: match.group(3)!.trim(),
    transactionAt: parseSmsDate(match.group(4)) ?? DateTime.now(),
    rawSms: rawSms,
    referenceNumber: match.group(5) ?? match.group(6),
  );
}

ParsedBankTransaction? parseSbiBankSms(String sms) {
  final normalized = normalizeSms(sms);

  final upiDebit = _sbiUpiDebitPattern.firstMatch(normalized);
  if (upiDebit != null) {
    return ParsedBankTransaction(
      bank: 'SBI',
      lastFourDigits: upiDebit.group(1)!,
      kind: BankTransactionKind.debit,
      amountPaise: rupeesToPaise(upiDebit.group(2)!),
      beneficiary: upiDebit.group(4)!.trim(),
      transactionAt: parseSmsDate(upiDebit.group(3)) ?? DateTime.now(),
      rawSms: sms,
      referenceNumber: upiDebit.group(5),
    );
  }

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

  final cardPaymentDebit = _sbiCardPaymentDebitPattern.firstMatch(normalized);
  if (cardPaymentDebit != null) {
    return ParsedBankTransaction(
      bank: 'SBI',
      lastFourDigits: cardPaymentDebit.group(1)!,
      kind: BankTransactionKind.debit,
      amountPaise: rupeesToPaise(cardPaymentDebit.group(2)!),
      beneficiary: cardPaymentDebit.group(4)!.trim(),
      transactionAt: parseSmsDate(cardPaymentDebit.group(3)) ?? DateTime.now(),
      rawSms: sms,
      isCardPayment: true,
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

  final hyphenCredit = _sbiHyphenCreditPattern.firstMatch(normalized);
  if (hyphenCredit != null) {
    return ParsedBankTransaction(
      bank: 'SBI',
      lastFourDigits: hyphenCredit.group(1)!,
      kind: BankTransactionKind.credit,
      amountPaise: rupeesToPaise(hyphenCredit.group(2)!),
      transactionAt: parseSmsDate(hyphenCredit.group(3)) ?? DateTime.now(),
      rawSms: sms,
      category: detectBankCreditCategory(sms),
    );
  }

  final maskedCredit = _sbiMaskedCreditPattern.firstMatch(normalized);
  if (maskedCredit != null) {
    return ParsedBankTransaction(
      bank: 'SBI',
      lastFourDigits: maskedCredit.group(1)!,
      kind: BankTransactionKind.credit,
      amountPaise: rupeesToPaise(maskedCredit.group(2)!),
      transactionAt: parseSmsDate(maskedCredit.group(3)) ?? DateTime.now(),
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
