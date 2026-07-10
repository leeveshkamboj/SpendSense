import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';

CardTransactionKind cardTransactionKindFromString(String kind) {
  switch (kind) {
    case 'expense':
      return CardTransactionKind.expense;
    case 'refund':
      return CardTransactionKind.refund;
    case 'cashback':
      return CardTransactionKind.cashback;
    case 'card_payment':
      return CardTransactionKind.cardPayment;
    case 'adjustment_charge':
      return CardTransactionKind.adjustmentCharge;
    case 'adjustment_credit':
      return CardTransactionKind.adjustmentCredit;
    default:
      for (final value in CardTransactionKind.values) {
        if (value.name == kind) {
          return value;
        }
      }
      return CardTransactionKind.expense;
  }
}

CardTransactionLine cardTransactionLineFrom(CardTransaction transaction) {
  return CardTransactionLine(
    kind: cardTransactionKindFromString(transaction.kind),
    amountPaise: transaction.amountPaise,
  );
}
