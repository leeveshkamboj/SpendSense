import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/engine/overpayment.dart';

void main() {
  group('Overpayment', () {
    test('applies full payment when amount matches outstanding', () {
      final allocation = allocatePayment(
        outstandingPaise: 50000,
        paymentPaise: 50000,
      );

      expect(allocation.appliedToCyclePaise, 50000);
      expect(allocation.surplusPaise, 0);
    });

    test('rolls surplus forward when payment exceeds outstanding', () {
      final allocation = allocatePayment(
        outstandingPaise: 50000,
        paymentPaise: 55000,
      );

      expect(allocation.appliedToCyclePaise, 50000);
      expect(allocation.surplusPaise, 5000);
    });

    test('applies surplus credit to next oldest unpaid cycle', () {
      final result = applySurplusToCycles(
        surplusPaise: 35000,
        cycleOutstandingPaise: [30000, 20000],
      );

      expect(result.appliedPerCyclePaise, [30000, 5000]);
      expect(result.remainingSurplusPaise, 0);
    });
  });
}
