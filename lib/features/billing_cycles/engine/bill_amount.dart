import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';

/// Net spend on a billing cycle in paise.
int calculateBillAmount(Iterable<CardTransactionLine> transactions) {
  var total = 0;

  for (final transaction in transactions) {
    switch (transaction.kind) {
      case CardTransactionKind.expense:
      case CardTransactionKind.adjustmentCharge:
        total += transaction.amountPaise;
      case CardTransactionKind.refund:
      case CardTransactionKind.cashback:
      case CardTransactionKind.adjustmentCredit:
        total -= transaction.amountPaise;
      case CardTransactionKind.cardPayment:
        break;
    }
  }

  return total;
}
