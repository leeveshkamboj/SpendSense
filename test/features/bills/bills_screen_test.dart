import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/bills_screen.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';

void main() {
  group('Bills screen', () {
    testWidgets('shows total and net outstanding for unpaid bills', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unpaidBillsProvider.overrideWith(
              (ref) async => [
                BillSummary(
                  cycleId: 1,
                  creditCardId: 1,
                  cardNickname: 'HDFC ••5534',
                  dueDate: DateTime(2026, 8, 2),
                  billAmountPaise: 50000,
                  paymentsAppliedPaise: 0,
                  totalOutstandingPaise: 50000,
                  netOutstandingPaise: 42000,
                  status: BillingCycleStatus.billed,
                ),
              ],
            ),
          ],
          child: const MaterialApp(home: BillsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HDFC ••5534'), findsOneWidget);
      expect(find.text('₹500'), findsOneWidget);
      expect(find.text('Net ₹420'), findsOneWidget);
      expect(find.textContaining('02/08/2026'), findsOneWidget);
      expect(find.textContaining('Tap to record payment'), findsOneWidget);
    });

    testWidgets('opens payment sheet when bill is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unpaidBillsProvider.overrideWith(
              (ref) async => [
                BillSummary(
                  cycleId: 1,
                  creditCardId: 1,
                  cardNickname: 'HDFC ••5534',
                  dueDate: DateTime(2026, 8, 2),
                  billAmountPaise: 50000,
                  paymentsAppliedPaise: 0,
                  totalOutstandingPaise: 50000,
                  netOutstandingPaise: 42000,
                  status: BillingCycleStatus.billed,
                ),
              ],
            ),
          ],
          child: const MaterialApp(home: BillsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('HDFC ••5534'));
      await tester.pumpAndSettle();

      expect(find.text('Mark as fully paid'), findsOneWidget);
      expect(find.text('Record partial payment'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });
  });
}
