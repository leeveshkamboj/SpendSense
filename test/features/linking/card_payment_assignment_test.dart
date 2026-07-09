import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/linking/domain/unpaid_cycle_candidate.dart';
import 'package:spendsense/features/linking/engine/card_payment_assignment.dart';

void main() {
  group('Card payment assignment', () {
    test('assigns payment to oldest unpaid cycle', () {
      final cycleId = selectCardPaymentCycle(
        unpaidCycles: [
          UnpaidCycleCandidate(
            cycleId: 1,
            endDate: DateTime(2026, 1, 15),
            outstandingPaise: 1000000,
          ),
          UnpaidCycleCandidate(
            cycleId: 2,
            endDate: DateTime(2026, 2, 15),
            outstandingPaise: 800000,
          ),
        ],
        paymentAmountPaise: 500000,
      );

      expect(cycleId, 1);
    });

    test('prefers exact outstanding match as tiebreaker', () {
      final cycleId = selectCardPaymentCycle(
        unpaidCycles: [
          UnpaidCycleCandidate(
            cycleId: 1,
            endDate: DateTime(2026, 1, 15),
            outstandingPaise: 1000000,
          ),
          UnpaidCycleCandidate(
            cycleId: 2,
            endDate: DateTime(2026, 2, 15),
            outstandingPaise: 500000,
          ),
        ],
        paymentAmountPaise: 500000,
      );

      expect(cycleId, 2);
    });
  });
}
