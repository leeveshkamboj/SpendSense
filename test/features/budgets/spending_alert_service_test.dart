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
    late BudgetRepository budgets;
    BudgetAlertThreshold? fired;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      final creditCards = CreditCardRepository(database);
      final transactions = CardTransactionRepository(database);
      budgets = BudgetRepository(
        database: database,
        creditCards: creditCards,
        cardTransactions: transactions,
      );
      fired = null;
    });

    tearDown(() async {
      await database.close();
    });

    test('skips alerts when notification permission denied', () async {
      await budgets.setMonthlyLimit(10000);

      final service = SpendingAlertService(
        budgets: budgets,
        permissionGateway: InMemoryNotificationPermissionGateway(
          NotificationPermissionState.denied,
        ),
        onAlert: ({required threshold, required spentPaise, required limitPaise}) {
          fired = threshold;
        },
      );

      await service.syncAlerts(asOf: DateTime(2026, 7, 10));
      expect(fired, isNull);
    });
  });
}
