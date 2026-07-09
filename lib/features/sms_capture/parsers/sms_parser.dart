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
import 'package:spendsense/features/sms_capture/parsers/sbi_parsers.dart';

ParsedSms? parseBankSms(String sms) {
  if (isOtpSms(sms)) {
    return null;
  }

  final cardCreditParsers = <ParsedCardCredit? Function(String)>[
    parseHdfcCardCreditSms,
  ];

  for (final parser in cardCreditParsers) {
    final parsed = parser(sms);
    if (parsed != null) {
      return ParsedCardCreditMessage(parsed);
    }
  }

  final cardParsers = <ParsedCardExpense? Function(String)>[
    parseHdfcCardExpenseSms,
    parseSbiCardExpenseSms,
    parseIciciCardExpenseSms,
    parseAxisCardExpenseSms,
    parseKotakCardExpenseSms,
  ];

  for (final parser in cardParsers) {
    final parsed = parser(sms);
    if (parsed != null) {
      return ParsedCardExpenseMessage(parsed);
    }
  }

  final bankParsers = <ParsedBankTransaction? Function(String)>[
    parseSbiBankSms,
    parseIciciBankSms,
    parseAxisBankSms,
    parseKotakBankSms,
  ];

  for (final parser in bankParsers) {
    final parsed = parser(sms);
    if (parsed != null) {
      return ParsedBankTransactionMessage(parsed);
    }
  }

  return null;
}
