import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_credit.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_sms.dart';
import 'package:spendsense/features/sms_capture/otp_filter.dart';
import 'package:spendsense/features/sms_capture/parsers/axis_parsers.dart';
import 'package:spendsense/features/sms_capture/parsers/hdfc_card_credit_parser.dart';
import 'package:spendsense/features/sms_capture/parsers/hdfc_card_expense_parser.dart';
import 'package:spendsense/features/sms_capture/parsers/icici_parsers.dart';
import 'package:spendsense/features/sms_capture/parsers/kotak_parsers.dart';
import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';
import 'package:spendsense/features/sms_capture/parsers/sbi_parsers.dart';

class SmsParseDiagnostic {
  const SmsParseDiagnostic({
    required this.outcome,
    this.parserName,
    this.bank,
    this.lastFourDigits,
    this.amountPaise,
    this.merchant,
    this.normalizedChanged = false,
  });

  final String outcome;
  final String? parserName;
  final String? bank;
  final String? lastFourDigits;
  final int? amountPaise;
  final String? merchant;
  final bool normalizedChanged;

  @override
  String toString() {
    final parts = <String>[outcome];
    if (parserName != null) parts.add('parser=$parserName');
    if (bank != null) parts.add('bank=$bank');
    if (lastFourDigits != null) parts.add('card=••$lastFourDigits');
    if (amountPaise != null) parts.add('amountPaise=$amountPaise');
    if (merchant != null) parts.add('merchant=$merchant');
    if (normalizedChanged) parts.add('unicode_normalized=true');
    return parts.join(' ');
  }
}

SmsParseDiagnostic diagnoseSmsParse(String sms) {
  if (isOtpSms(sms)) {
    return const SmsParseDiagnostic(outcome: 'skipped_otp');
  }

  final normalizedChanged = deunicodeSms(sms) != sms;

  final cardCreditParsers = <(String, ParsedCardCredit? Function(String))>[
    ('hdfc_card_credit', parseHdfcCardCreditSms),
  ];
  for (final (name, parser) in cardCreditParsers) {
    final parsed = parser(sms);
    if (parsed != null) {
      return SmsParseDiagnostic(
        outcome: 'parsed_card_credit',
        parserName: name,
        bank: parsed.bank,
        lastFourDigits: parsed.lastFourDigits,
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        normalizedChanged: normalizedChanged,
      );
    }
  }

  final cardParsers = <(String, ParsedCardExpense? Function(String))>[
    ('hdfc_card_expense', parseHdfcCardExpenseSms),
    ('sbi_card_expense', parseSbiCardExpenseSms),
    ('icici_card_expense', parseIciciCardExpenseSms),
    ('axis_card_expense', parseAxisCardExpenseSms),
    ('kotak_card_expense', parseKotakCardExpenseSms),
  ];
  for (final (name, parser) in cardParsers) {
    final parsed = parser(sms);
    if (parsed != null) {
      return SmsParseDiagnostic(
        outcome: 'parsed_card_expense',
        parserName: name,
        bank: parsed.bank,
        lastFourDigits: parsed.lastFourDigits,
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        normalizedChanged: normalizedChanged,
      );
    }
  }

  final bankParsers = <(String, ParsedBankTransaction? Function(String))>[
    ('sbi_bank', parseSbiBankSms),
    ('icici_bank', parseIciciBankSms),
    ('axis_bank', parseAxisBankSms),
    ('kotak_bank', parseKotakBankSms),
  ];
  for (final (name, parser) in bankParsers) {
    final parsed = parser(sms);
    if (parsed != null) {
      return SmsParseDiagnostic(
        outcome: 'parsed_bank_transaction',
        parserName: name,
        bank: parsed.bank,
        lastFourDigits: parsed.lastFourDigits,
        amountPaise: parsed.amountPaise,
        merchant: parsed.beneficiary ?? parsed.merchant,
        normalizedChanged: normalizedChanged,
      );
    }
  }

  return SmsParseDiagnostic(
    outcome: 'no_parser_match',
    normalizedChanged: normalizedChanged,
  );
}

String describeParsedSms(ParsedSms parsed) {
  return switch (parsed) {
    ParsedCardExpenseMessage(:final expense) =>
      'card_expense bank=${expense.bank} ••${expense.lastFourDigits} '
      'amountPaise=${expense.amountPaise} merchant=${expense.merchant}',
    ParsedCardCreditMessage(:final credit) =>
      'card_credit bank=${credit.bank} ••${credit.lastFourDigits} '
      'amountPaise=${credit.amountPaise}',
    ParsedBankTransactionMessage(:final transaction) =>
      'bank_txn bank=${transaction.bank} ••${transaction.lastFourDigits} '
      'kind=${transaction.kind.name} amountPaise=${transaction.amountPaise}',
  };
}
