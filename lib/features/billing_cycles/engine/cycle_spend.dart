import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';

/// Net card spend for a billing cycle (charges minus credits, excluding payments).
int calculateCycleNetSpendPaise(Iterable<CardTransaction> transactions) {
  return calculateBillAmount(transactions.map(cardTransactionLineFrom));
}
