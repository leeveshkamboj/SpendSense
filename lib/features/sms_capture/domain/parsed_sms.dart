import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';

sealed class ParsedSms {
  const ParsedSms();
}

class ParsedCardExpenseMessage extends ParsedSms {
  const ParsedCardExpenseMessage(this.expense);

  final ParsedCardExpense expense;
}

class ParsedBankTransactionMessage extends ParsedSms {
  const ParsedBankTransactionMessage(this.transaction);

  final ParsedBankTransaction transaction;
}
