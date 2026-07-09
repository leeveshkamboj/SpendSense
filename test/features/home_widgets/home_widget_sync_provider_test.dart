import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_providers.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_sync_service.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_writer.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

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
  group('homeWidgetSyncProvider', () {
    late AppDatabase database;
    late _RecordingHomeWidgetWriter writer;
    late ProviderContainer container;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      writer = _RecordingHomeWidgetWriter();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          homeWidgetWriterProvider.overrideWithValue(writer),
        ],
      );

      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
          creditLimitPaise: 200000,
        ),
      );
      await creditCards.configureBilling(
        cardId: cardId,
        billDayOfMonth: 15,
        dueDateOffsetDays: 18,
        historyFrom: DateTime(2026, 1, 1),
        historyTo: DateTime(2026, 12, 31),
      );
      final cycle = (await creditCards.listCycles(cardId))
          .firstWhere((row) => row.startDate == DateTime(2026, 6, 16));
      await transactions.insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: cycle.id,
          kind: 'expense',
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );
      await BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      ).setMonthlyLimit(100000);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('publishes all six widget datasets on app launch', () async {
      await container.read(homeWidgetSyncProvider.future);

      expect(
        writer.values.keys,
        containsAll([
          HomeWidgetKeys.quickSummarySpent,
          HomeWidgetKeys.quickSummaryBudgetLimit,
          HomeWidgetKeys.quickSummaryRemaining,
          HomeWidgetKeys.quickSummaryCardChartJson,
          HomeWidgetKeys.creditUtilizationSpent,
          HomeWidgetKeys.creditUtilizationLimit,
          HomeWidgetKeys.creditUtilizationNeedsLimit,
          HomeWidgetKeys.creditUtilizationCardsJson,
          HomeWidgetKeys.recentTransactionsJson,
          HomeWidgetKeys.billsJson,
          HomeWidgetKeys.budgetSpent,
          HomeWidgetKeys.budgetLimit,
          HomeWidgetKeys.budgetRemaining,
          HomeWidgetKeys.budgetDaily,
          HomeWidgetKeys.budgetNeedsPrompt,
          HomeWidgetKeys.budgetCardChartJson,
        ]),
      );
      expect(writer.values['quick_summary_spent'], '50000');
      expect(writer.values['credit_utilization_limit'], '200000');
      expect(writer.values['recent_transactions_json'], contains('ZOMATO LTD'));
      expect(writer.updateCount, greaterThanOrEqualTo(5));
    });
  });
}
