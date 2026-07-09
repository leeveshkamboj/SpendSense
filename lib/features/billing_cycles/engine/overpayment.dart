class PaymentAllocation {
  const PaymentAllocation({
    required this.appliedToCyclePaise,
    required this.surplusPaise,
  });

  final int appliedToCyclePaise;
  final int surplusPaise;
}

class SurplusApplicationResult {
  const SurplusApplicationResult({
    required this.appliedPerCyclePaise,
    required this.remainingSurplusPaise,
  });

  final List<int> appliedPerCyclePaise;
  final int remainingSurplusPaise;
}

PaymentAllocation allocatePayment({
  required int outstandingPaise,
  required int paymentPaise,
}) {
  if (paymentPaise <= outstandingPaise) {
    return PaymentAllocation(
      appliedToCyclePaise: paymentPaise,
      surplusPaise: 0,
    );
  }

  return PaymentAllocation(
    appliedToCyclePaise: outstandingPaise,
    surplusPaise: paymentPaise - outstandingPaise,
  );
}

/// Applies [surplusPaise] to [cycleOutstandingPaise] oldest-first.
SurplusApplicationResult applySurplusToCycles({
  required int surplusPaise,
  required List<int> cycleOutstandingPaise,
}) {
  var remaining = surplusPaise;
  final applied = <int>[];

  for (final outstanding in cycleOutstandingPaise) {
    final appliedHere = remaining < outstanding ? remaining : outstanding;
    applied.add(appliedHere);
    remaining -= appliedHere;
    if (remaining == 0) {
      break;
    }
  }

  while (applied.length < cycleOutstandingPaise.length) {
    applied.add(0);
  }

  return SurplusApplicationResult(
    appliedPerCyclePaise: applied,
    remainingSurplusPaise: remaining,
  );
}
