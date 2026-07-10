import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/credit_cards/engine/credit_limit_utilization.dart';

String formatCreditCardLimitLabel({
  required CreditCard card,
  CreditLimitPool? pool,
}) {
  if (pool != null) {
    return 'Shared limit: ${formatPaise(pool.creditLimitPaise)} (${pool.name})';
  }
  if (card.creditLimitPaise != null) {
    return 'Credit limit: ${formatPaise(card.creditLimitPaise!)}';
  }
  return 'Credit limit not set';
}

bool creditCardNeedsLimitSetup(CreditCard card) {
  return !cardHasConfiguredCreditLimit(card);
}
