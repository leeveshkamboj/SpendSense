import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/analytics/analytics_screen.dart';
import 'package:spendsense/features/analytics/data/analytics_providers.dart';
import 'package:spendsense/features/analytics/domain/analytics_snapshot.dart';
import 'package:spendsense/features/analytics/domain/billing_cycle_comparison.dart';
import 'package:spendsense/features/analytics/presentation/analytics_chart_type.dart';

void main() {
  group('Analytics screen', () {
    testWidgets('defaults to budget month comparison with chart controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsSnapshotProvider.overrideWith(
              (ref) async => AnalyticsSnapshot(
                currentPeriodStart: DateTime(2026, 6, 16),
                previousPeriodStart: DateTime(2026, 5, 16),
                currentCategoryTotals: const {'Food': 50000},
                previousCategoryTotals: const {'Food': 20000},
                currentMerchantTotals: const {'ZOMATO LTD': 50000},
                previousMerchantTotals: const {'SWIGGY': 20000},
                currentCardTotals: const {'HDFC ••5534': 50000},
                previousCardTotals: const {'HDFC ••5534': 20000},
                currentTagTotals: const {},
                previousTagTotals: const {},
              ),
            ),
            activeCreditCardsForAnalyticsProvider.overrideWith(
              (ref) async => [
                CreditCard(
                  id: 1,
                  bank: 'HDFC',
                  lastFourDigits: '5534',
                  nickname: 'HDFC ••5534',
                  billDayOfMonth: 15,
                  dueDateOffsetDays: 18,
                  colorValue: 0,
                  iconName: 'credit_card',
                  isArchived: false,
                  createdAt: DateTime(2026, 1, 1),
                ),
              ],
            ),
            billingCycleComparisonProvider.overrideWith(
              (ref, cardId) async => const BillingCycleComparison(
                cardNickname: 'HDFC ••5534',
                currentCycleLabel: '16/06/2026 – 15/07/2026',
                previousCycleLabel: '16/05/2026 – 15/06/2026',
                currentSpendPaise: 50000,
                previousSpendPaise: 20000,
              ),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Current: 16/06/2026'), findsOneWidget);
      expect(find.textContaining('Previous: 16/05/2026'), findsOneWidget);
      for (final chartType in AnalyticsChartType.values) {
        expect(find.text(chartType.label), findsOneWidget);
      }
      for (final breakdown in AnalyticsBreakdown.values) {
        expect(find.text(breakdown.label), findsWidgets);
      }
      expect(find.text('Billing Cycle Comparison'), findsOneWidget);
      expect(find.textContaining('16/06/2026 – 15/07/2026'), findsOneWidget);
      expect(find.textContaining('₹500'), findsWidgets);
    });
  });
}
