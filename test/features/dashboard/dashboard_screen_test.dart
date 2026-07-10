import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';
import 'package:spendsense/features/dashboard/dashboard_screen.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_spend_summary.dart';
import 'package:spendsense/features/dashboard/domain/dashboard_recent_transaction.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';

BillSummary _sampleBill() {
  return BillSummary(
    cycleId: 1,
    creditCardId: 1,
    cardNickname: 'HDFC ••5534',
    dueDate: DateTime(2026, 8, 2),
    billAmountPaise: 50000,
    paymentsAppliedPaise: 0,
    totalOutstandingPaise: 50000,
    netOutstandingPaise: 42000,
    status: BillingCycleStatus.billed,
  );
}

void main() {
  group('Dashboard screen', () {
    testWidgets('shows aggregate and per-card spend', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardCardSpendProvider.overrideWith(
              (ref) async => const DashboardSpendSummary(
                totalPaise: 80000,
                cards: [
                  DashboardCardSpend(nickname: 'HDFC ••5534', spentPaise: 50000),
                  DashboardCardSpend(nickname: 'SBI ••1234', spentPaise: 30000),
                ],
              ),
            ),
            monthlyBudgetProgressProvider.overrideWith((ref) async => null),
            unpaidBillsProvider.overrideWith((ref) async => []),
            dashboardRecentTransactionsProvider.overrideWith((ref) async => []),
            spendingAlertSyncProvider.overrideWith((ref) async {}),
            recoverableSummaryProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('₹800'), findsOneWidget);
      expect(find.textContaining('Across 2 cards'), findsOneWidget);
      expect(find.textContaining('₹500'), findsWidgets);
      expect(find.textContaining('₹300'), findsOneWidget);
    });

    testWidgets('shows budget used, remaining, and projection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardCardSpendProvider.overrideWith(
              (ref) async => const DashboardSpendSummary(
                totalPaise: 0,
                cards: [],
              ),
            ),
            monthlyBudgetProgressProvider.overrideWith(
              (ref) async => BudgetProgressSnapshot(
                limitPaise: 100000,
                spentPaise: 50000,
                projectedPaise: 80000,
                periodStart: DateTime(2026, 7, 1),
                periodEnd: DateTime(2026, 7, 31),
              ),
            ),
            unpaidBillsProvider.overrideWith((ref) async => []),
            dashboardRecentTransactionsProvider.overrideWith((ref) async => []),
            spendingAlertSyncProvider.overrideWith((ref) async {}),
            recoverableSummaryProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('₹500'), findsWidgets);
      expect(find.textContaining('remaining'), findsOneWidget);
      expect(find.textContaining('projected'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows upcoming unpaid bills', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardCardSpendProvider.overrideWith(
              (ref) async => const DashboardSpendSummary(
                totalPaise: 0,
                cards: [],
              ),
            ),
            monthlyBudgetProgressProvider.overrideWith((ref) async => null),
            unpaidBillsProvider.overrideWith((ref) async => [_sampleBill()]),
            dashboardRecentTransactionsProvider.overrideWith((ref) async => []),
            spendingAlertSyncProvider.overrideWith((ref) async {}),
            recoverableSummaryProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming Bills'), findsOneWidget);
      expect(find.text('HDFC ••5534'), findsOneWidget);
      expect(find.textContaining('02/08/2026'), findsOneWidget);
      expect(find.text('₹500'), findsOneWidget);
      expect(find.text('Net ₹420'), findsOneWidget);
    });

    testWidgets('shows recent transactions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardCardSpendProvider.overrideWith(
              (ref) async => const DashboardSpendSummary(
                totalPaise: 0,
                cards: [],
              ),
            ),
            monthlyBudgetProgressProvider.overrideWith((ref) async => null),
            unpaidBillsProvider.overrideWith((ref) async => []),
            dashboardRecentTransactionsProvider.overrideWith(
              (ref) async => [
                DashboardRecentTransaction(
                  id: 1,
                  merchant: 'ZOMATO LTD',
                  amountPaise: 41167,
                  transactionAt: DateTime(2026, 7, 9, 16, 15),
                  colorValue: 0xFF00695C,
                  cardNickname: 'HDFC ••5534',
                  kind: 'expense',
                ),
              ],
            ),
            spendingAlertSyncProvider.overrideWith((ref) async {}),
            recoverableSummaryProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Zomato Ltd'), findsOneWidget);
      expect(find.textContaining('₹411.67'), findsOneWidget);
    });
  });
}
