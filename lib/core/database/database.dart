import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:spendsense/core/database/app_settings_table.dart';
import 'package:spendsense/features/accounts/data/bank_account_transactions_table.dart';
import 'package:spendsense/features/accounts/data/bank_accounts_table.dart';
import 'package:spendsense/features/billing_cycles/data/billing_cycles_table.dart';
import 'package:spendsense/features/budgets/data/budget_tables.dart';
import 'package:spendsense/features/credit_cards/data/credit_cards_table.dart';
import 'package:spendsense/features/recoverables/data/recoverables_tables.dart';
import 'package:spendsense/features/transactions/data/card_transactions_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    CreditCards,
    BillingCycles,
    BankAccounts,
    CardTransactions,
    BankAccountTransactions,
    AppSettings,
    BudgetSettings,
    CategoryBudgets,
    BudgetAlertCrossings,
    RecoveryLinks,
    RecoverablePersons,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'spendsense'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(creditCards);
            await m.createTable(billingCycles);
            await m.createTable(bankAccounts);
          }
          if (from < 3) {
            await m.createTable(cardTransactions);
          }
          if (from < 4) {
            await m.createTable(bankAccountTransactions);
            await m.createTable(appSettings);
          }
          if (from < 5) {
            await m.addColumn(cardTransactions, cardTransactions.category);
            await m.addColumn(cardTransactions, cardTransactions.isRecoverable);
            await m.createTable(budgetSettings);
            await m.createTable(categoryBudgets);
            await m.createTable(budgetAlertCrossings);
          }
          if (from < 6) {
            await m.addColumn(
              cardTransactions,
              cardTransactions.recoverablePerson,
            );
            await m.createTable(recoveryLinks);
            await m.createTable(recoverablePersons);
          }
        },
      );
}
