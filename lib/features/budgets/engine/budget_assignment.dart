import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';

DateTime budgetPeriodStartForTransaction({
  required DateTime transactionDate,
  required int billDayOfMonth,
  bool unifiedRolloverActive = false,
}) {
  if (unifiedRolloverActive) {
    final cycle = billingCycleContaining(
      transactionDate: transactionDate,
      billDayOfMonth: billDayOfMonth,
    );
    final nextCycleStart = DateTime(
      cycle.endDate.year,
      cycle.endDate.month,
      cycle.endDate.day + 1,
    );
    return billingCycleContaining(
      transactionDate: nextCycleStart,
      billDayOfMonth: billDayOfMonth,
    ).startDate;
  }

  final cycle = billingCycleContaining(
    transactionDate: transactionDate,
    billDayOfMonth: billDayOfMonth,
  );
  final billDate = DateTime(
    cycle.endDate.year,
    cycle.endDate.month,
    cycle.endDate.day,
  );
  final txnDate = DateTime(
    transactionDate.year,
    transactionDate.month,
    transactionDate.day,
  );

  if (txnDate.isBefore(billDate)) {
    return cycle.startDate;
  }

  final nextCycleStart = DateTime(
    cycle.endDate.year,
    cycle.endDate.month,
    cycle.endDate.day + 1,
  );
  return billingCycleContaining(
    transactionDate: nextCycleStart,
    billDayOfMonth: billDayOfMonth,
  ).startDate;
}

bool isUnifiedRolloverActive({
  required DateTime asOf,
  required Iterable<CardBillingState> cards,
}) {
  final configuredCards = cards.where((card) => card.billDayOfMonth != null);
  if (configuredCards.isEmpty) {
    return false;
  }

  for (final card in configuredCards) {
    final cycle = billingCycleContaining(
      transactionDate: asOf,
      billDayOfMonth: card.billDayOfMonth!,
    );
    final billDate = DateTime(
      cycle.endDate.year,
      cycle.endDate.month,
      cycle.endDate.day,
    );
    final asOfDate = DateTime(asOf.year, asOf.month, asOf.day);

    if (!card.billGeneratedForCurrentCycle || asOfDate.isBefore(billDate)) {
      return false;
    }
  }

  return true;
}

class CardBillingState {
  const CardBillingState({
    required this.cardId,
    required this.billDayOfMonth,
    required this.billGeneratedForCurrentCycle,
  });

  final int cardId;
  final int? billDayOfMonth;
  final bool billGeneratedForCurrentCycle;
}
