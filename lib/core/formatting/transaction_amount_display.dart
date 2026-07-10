import 'package:flutter/material.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';

enum TransactionDirection {
  debit,
  credit,
  neutral,
}

TransactionDirection cardTransactionDirection(String kind) {
  switch (cardTransactionKindFromString(kind)) {
    case CardTransactionKind.expense:
    case CardTransactionKind.adjustmentCharge:
      return TransactionDirection.debit;
    case CardTransactionKind.refund:
    case CardTransactionKind.cashback:
    case CardTransactionKind.adjustmentCredit:
      return TransactionDirection.credit;
    case CardTransactionKind.cardPayment:
      return TransactionDirection.neutral;
  }
}

TransactionDirection bankTransactionDirection(String kind) {
  return kind == 'credit'
      ? TransactionDirection.credit
      : TransactionDirection.debit;
}

String transactionDirectionLabel(TransactionDirection direction) {
  switch (direction) {
    case TransactionDirection.debit:
      return 'Debit';
    case TransactionDirection.credit:
      return 'Credit';
    case TransactionDirection.neutral:
      return 'Payment';
  }
}

String formatSignedPaise(int paise, TransactionDirection direction) {
  final formatted = formatPaise(paise);
  switch (direction) {
    case TransactionDirection.debit:
      return '−$formatted';
    case TransactionDirection.credit:
      return '+$formatted';
    case TransactionDirection.neutral:
      return formatted;
  }
}

Color transactionDirectionColor(
  ColorScheme scheme,
  TransactionDirection direction,
) {
  final isDark = scheme.brightness == Brightness.dark;
  switch (direction) {
    case TransactionDirection.debit:
      return isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828);
    case TransactionDirection.credit:
      return isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);
    case TransactionDirection.neutral:
      return scheme.onSurfaceVariant;
  }
}
