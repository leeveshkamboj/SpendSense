import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/budgets/data/spending_alert_service.dart';
import 'package:spendsense/features/budgets/engine/budget_alerts.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

void main() {
  group('SpendingAlertService', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CardTransactionRepository transactions;
    late BudgetRepository budgets;
    BudgetAlertThreshold? fired;
    bool? capturedNotificationsGranted;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      transactions = CardTransactionRepository(database);
      budgets = BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      );
      fired = null;
      capturedNotificationsGranted = null;
    });

    tearDown(() async {
      await database.close();
    });

    test('fires in-app alert when notification permission denied', () async {
      await budgets.setMonthlyLimit(10000);

      final cardId = await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
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
          amountPaise: 8000,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9),
          source: 'SMS',
        ),
      );

      final service = SpendingAlertService(
        budgets: budgets,
        permissionGateway: InMemoryNotificationPermissionGateway(
          NotificationPermissionState.denied,
        ),
        onAlert: ({
          required threshold,
          required spentPaise,
          required limitPaise,
          required bool notificationsGranted,
        }) {
          fired = threshold;
          capturedNotificationsGranted = notificationsGranted;
        },
      );

      await service.syncAlerts(asOf: DateTime(2026, 7, 10));

      expect(fired, BudgetAlertThreshold.seventyFivePercent);
      expect(capturedNotificationsGranted, isFalse);
    });
  });
}
