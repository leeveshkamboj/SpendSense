import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/bills/domain/net_outstanding.dart';

void main() {
  group('Net outstanding', () {
    test('total outstanding is bill amount minus payments applied', () {
      expect(
        calculateTotalOutstanding(
          billAmountPaise: 50000,
          paymentsAppliedPaise: 20000,
        ),
        30000,
      );
    });

    test('net outstanding subtracts unsettled recoverables from total', () {
      expect(
        calculateNetOutstanding(
          totalOutstandingPaise: 30000,
          unsettledRecoverablePaise: 8000,
        ),
        22000,
      );
    });

    test('net outstanding equals total when no recoverables', () {
      expect(
        calculateNetOutstanding(
          totalOutstandingPaise: 30000,
          unsettledRecoverablePaise: 0,
        ),
        30000,
      );
    });
  });
}
