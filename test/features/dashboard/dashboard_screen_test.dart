import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/dashboard/dashboard_screen.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';

void main() {
  group('Dashboard screen', () {
    testWidgets('shows budget used, remaining, and projection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyBudgetProgressProvider.overrideWith(
              (ref) async => BudgetProgressSnapshot(
                limitPaise: 100000,
                spentPaise: 50000,
                projectedPaise: 80000,
                periodStart: DateTime(2026, 7, 1),
                periodEnd: DateTime(2026, 7, 31),
              ),
            ),
            spendingAlertSyncProvider.overrideWith((ref) async {}),
            recoverableSummaryProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('₹500 used of ₹1000'), findsOneWidget);
      expect(find.textContaining('₹500 remaining'), findsOneWidget);
      expect(find.textContaining('Projected ₹800'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
