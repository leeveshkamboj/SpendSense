import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_sync_service.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_writer.dart';
import 'package:spendsense/features/home_widgets/domain/card_spend_chart_segment.dart';
import 'package:spendsense/features/home_widgets/domain/card_utilization_segment.dart';
import 'package:spendsense/features/home_widgets/domain/credit_utilization_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/quick_summary_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/recent_transactions_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/bills_widget_snapshot.dart';
import 'package:spendsense/features/home_widgets/domain/budget_widget_snapshot.dart';

class _RecordingHomeWidgetWriter implements HomeWidgetWriter {
  final values = <String, String>{};
  var updateCount = 0;

  @override
  Future<void> saveValue(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> updateAllWidgets() async {
    updateCount++;
  }
}

void main() {
  group('HomeWidgetSyncService', () {
    test('publishes quick summary data to the home widget store', () async {
      final writer = _RecordingHomeWidgetWriter();
      final service = HomeWidgetSyncService(writer: writer);

      await service.publishQuickSummary(
        const QuickSummaryWidgetSnapshot(
          spentPaise: 50000,
          budgetLimitPaise: 100000,
          budgetRemainingPaise: 50000,
          cardSpendSegments: [
            CardSpendChartSegment(
              nickname: 'HDFC ••5534',
              spentPaise: 50000,
              colorValue: 0xFF00695C,
            ),
          ],
        ),
      );

      expect(writer.values['quick_summary_spent'], '50000');
      expect(writer.values['quick_summary_budget_limit'], '100000');
      expect(writer.values['quick_summary_remaining'], '50000');
      expect(
        writer.values['quick_summary_card_chart_json'],
        contains('"color_value":${0xFF00695C}'),
      );
      expect(writer.updateCount, 1);
    });

    test('publishes credit utilization data to the home widget store', () async {
      final writer = _RecordingHomeWidgetWriter();
      final service = HomeWidgetSyncService(writer: writer);

      await service.publishCreditUtilization(
        const CreditUtilizationWidgetSnapshot(
          spentPaise: 50000,
          creditLimitPaise: 200000,
          needsLimitPrompt: false,
          cardSegments: [
            CardUtilizationSegment(
              nickname: 'HDFC ••5534',
              spentPaise: 50000,
              creditLimitPaise: 200000,
              colorValue: 0xFF00695C,
            ),
          ],
        ),
      );

      expect(writer.values['credit_utilization_spent'], '50000');
      expect(writer.values['credit_utilization_limit'], '200000');
      expect(writer.values['credit_utilization_needs_limit'], 'false');
      expect(
        writer.values['credit_utilization_cards_json'],
        contains('"color_value":${0xFF00695C}'),
      );
      expect(writer.updateCount, 1);
    });

    test('publishes recent transactions as json to the home widget store', () async {
      final writer = _RecordingHomeWidgetWriter();
      final service = HomeWidgetSyncService(writer: writer);
      final at = DateTime(2026, 7, 9, 14, 30);

      await service.publishRecentTransactions(
        RecentTransactionsWidgetSnapshot(
          transactions: [
            RecentTransactionWidgetItem(
              merchant: 'NEWER',
              amountPaise: 20000,
              transactionAt: at,
              colorValue: 0xFF00695C,
              kind: 'expense',
            ),
          ],
        ),
      );

      expect(
        writer.values['recent_transactions_json'],
        contains('"color_value":${0xFF00695C}'),
      );
      expect(writer.updateCount, 1);
    });

    test('publishes upcoming bills as json to the home widget store', () async {
      final writer = _RecordingHomeWidgetWriter();
      final service = HomeWidgetSyncService(writer: writer);
      final dueDate = DateTime(2026, 8, 2);

      await service.publishBills(
        BillsWidgetSnapshot(
          bills: [
            BillWidgetItem(
              cardNickname: 'HDFC ••5534',
              dueDate: dueDate,
              netOutstandingPaise: 50000,
              colorValue: 0xFF00695C,
            ),
          ],
        ),
      );

      expect(
        writer.values['bills_json'],
        contains('"color_value":${0xFF00695C}'),
      );
      expect(writer.updateCount, 1);
    });

    test('publishes budget progress to the home widget store', () async {
      final writer = _RecordingHomeWidgetWriter();
      final service = HomeWidgetSyncService(writer: writer);

      await service.publishBudget(
        const BudgetWidgetSnapshot(
          spentPaise: 50000,
          limitPaise: 100000,
          remainingPaise: 50000,
          dailyBudgetPaise: 2500,
          needsBudgetPrompt: false,
          cardSpendSegments: [
            CardSpendChartSegment(
              nickname: 'HDFC ••5534',
              spentPaise: 50000,
              colorValue: 0xFF00695C,
            ),
          ],
        ),
      );

      expect(writer.values['budget_spent'], '50000');
      expect(writer.values['budget_limit'], '100000');
      expect(writer.values['budget_remaining'], '50000');
      expect(writer.values['budget_daily'], '2500');
      expect(writer.values['budget_needs_prompt'], 'false');
      expect(
        writer.values['budget_card_chart_json'],
        contains('"color_value":${0xFF00695C}'),
      );
      expect(writer.updateCount, 1);
    });
  });
}
