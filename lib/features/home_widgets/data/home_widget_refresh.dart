import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_repository.dart';
import 'package:spendsense/features/dashboard/data/dashboard_repository.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_repository.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_sync_service.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_writer.dart';
import 'package:spendsense/features/home_widgets/data/platform_home_widget_writer.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

/// Rebuilds Android home-screen widgets from [database].
///
/// Safe to call from the SMS background isolate — does not require Riverpod or
/// the main UI engine to be alive.
Future<void> refreshHomeWidgets(
  AppDatabase database, {
  HomeWidgetWriter? writer,
  DateTime? asOf,
}) async {
  final creditCards = CreditCardRepository(database);
  final cardTransactions = CardTransactionRepository(database);
  final repository = HomeWidgetRepository(
    dashboard: DashboardRepository(
      creditCards: creditCards,
      cardTransactions: cardTransactions,
    ),
    budgets: BudgetRepository(
      database: database,
      creditCards: creditCards,
      cardTransactions: cardTransactions,
    ),
    creditCards: creditCards,
    creditLimitPools: CreditLimitPoolRepository(database),
    bills: BillsRepository(
      creditCards: creditCards,
      transactions: cardTransactions,
      recoverables: RecoverableRepository(
        database: database,
        transactions: cardTransactions,
      ),
    ),
  );
  final sync = HomeWidgetSyncService(
    writer: writer ?? PlatformHomeWidgetWriter(),
  );
  final now = asOf ?? DateTime.now();

  await sync.publishQuickSummary(await repository.quickSummary(asOf: now));
  await sync.publishCreditUtilization(
    await repository.creditUtilization(asOf: now),
  );
  await sync.publishRecentTransactions(await repository.recentTransactions());
  await sync.publishBills(await repository.upcomingBills(asOf: now));
  await sync.publishBudget(await repository.budgetProgress(asOf: now));
}
