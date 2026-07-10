import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';

String reportCardDirectionLabel(String kind) {
  switch (cardTransactionKindFromString(kind)) {
    case CardTransactionKind.expense:
    case CardTransactionKind.adjustmentCharge:
      return 'Debit';
    case CardTransactionKind.refund:
    case CardTransactionKind.cashback:
    case CardTransactionKind.adjustmentCredit:
      return 'Credit';
    case CardTransactionKind.cardPayment:
      return 'Payment';
  }
}

String reportBankDirectionLabel(String kind) {
  return kind == 'credit' ? 'Credit' : 'Debit';
}

String reportSignedAmount(int paise, String directionLabel) {
  final formatted = formatPaise(paise);
  return switch (directionLabel) {
    'Debit' => '-$formatted',
    'Credit' => '+$formatted',
    _ => formatted,
  };
}
