import 'package:spendsense/features/linking/domain/unpaid_cycle_candidate.dart';

int? selectCardPaymentCycle({
  required List<UnpaidCycleCandidate> unpaidCycles,
  required int paymentAmountPaise,
}) {
  if (unpaidCycles.isEmpty) return null;

  final sorted = [...unpaidCycles]
    ..sort((a, b) => a.endDate.compareTo(b.endDate));

  final exactMatch = sorted
      .where((cycle) => cycle.outstandingPaise == paymentAmountPaise)
      .toList();
  if (exactMatch.isNotEmpty) {
    return exactMatch.first.cycleId;
  }

  return sorted.first.cycleId;
}
