import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:spendsense/core/database/app_settings_table.dart';
import 'package:spendsense/features/accounts/data/bank_account_transactions_table.dart';
import 'package:spendsense/features/accounts/data/bank_accounts_table.dart';
import 'package:spendsense/features/billing_cycles/data/billing_cycles_table.dart';
import 'package:spendsense/features/budgets/data/budget_tables.dart';
import 'package:spendsense/features/categories/data/categories_table.dart';
import 'package:spendsense/features/credit_cards/data/credit_cards_table.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pools_table.dart';
import 'package:spendsense/features/linking/data/linking_tables.dart';
import 'package:spendsense/features/merchants/data/merchants_table.dart';
import 'package:spendsense/features/recoverables/data/recoverables_tables.dart';
import 'package:spendsense/features/tags/data/tags_tables.dart';
import 'package:spendsense/features/transactions/data/card_transaction_receipts_table.dart';
import 'package:spendsense/features/transactions/data/card_transactions_table.dart';
import 'package:spendsense/features/sms_capture/data/sms_senders_table.dart';
import 'package:spendsense/features/sms_capture/data/seen_sms_bodies_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    CreditLimitPools,
    CreditCards,
    BillingCycles,
    BankAccounts,
    CardTransactions,
    CardTransactionReceipts,
    BankAccountTransactions,
    AppSettings,
    BudgetSettings,
    CategoryBudgets,
    BudgetAlertCrossings,
    RecoveryLinks,
    RecoverablePersons,
    Merchants,
    Categories,
    Tags,
    CardTransactionTags,
    MerchantDefaultTags,
    TransactionLinks,
    SmsSenders,
    SeenSmsBodies,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'spendsense'));

  @override
  int get schemaVersion => 16;

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
          if (from < 7) {
            await m.createTable(merchants);
          }
          if (from < 8) {
            await m.createTable(categories);
          }
          if (from < 9) {
            await m.createTable(tags);
            await m.createTable(cardTransactionTags);
            await m.createTable(merchantDefaultTags);
          }
          if (from < 10) {
            await m.createTable(transactionLinks);
          }
          if (from < 11) {
            await m.addColumn(cardTransactions, cardTransactions.notes);
            await m.addColumn(cardTransactions, cardTransactions.location);
            await m.addColumn(
              bankAccountTransactions,
              bankAccountTransactions.notes,
            );
            await m.addColumn(
              bankAccountTransactions,
              bankAccountTransactions.location,
            );
            await m.createTable(cardTransactionReceipts);
          }
          if (from < 12) {
            await m.createTable(smsSenders);
            await m.addColumn(
              appSettings,
              appSettings.locationPermissionExplained,
            );
            await m.addColumn(appSettings, appSettings.themeMode);
            await m.addColumn(appSettings, appSettings.appLockEnabled);
            await m.addColumn(appSettings, appSettings.appLockBiometricEnabled);
            await m.addColumn(
              budgetSettings,
              budgetSettings.alertThreshold75,
            );
            await m.addColumn(
              budgetSettings,
              budgetSettings.alertThreshold90,
            );
            await m.addColumn(
              budgetSettings,
              budgetSettings.alertThreshold100,
            );
          }
          if (from < 13) {
            await m.createTable(creditLimitPools);
            await m.addColumn(
              creditCards,
              creditCards.creditLimitPoolId,
            );
          }
          if (from < 14) {
            await m.addColumn(appSettings, appSettings.lastSmsSyncAtMs);
          }
          if (from < 15) {
            await m.addColumn(
              appSettings,
              appSettings.smsImportWindowMonths,
            );
            await m.addColumn(cardTransactions, cardTransactions.isRecurring);
            await m.addColumn(
              bankAccountTransactions,
              bankAccountTransactions.isRecurring,
            );
          }
          if (from < 16) {
            await m.createTable(seenSmsBodies);
            await customStatement(
              'INSERT OR IGNORE INTO seen_sms_bodies (body, created_at) '
              'SELECT raw_sms, created_at FROM card_transactions '
              "WHERE raw_sms IS NOT NULL AND trim(raw_sms) != ''",
            );
            await customStatement(
              'INSERT OR IGNORE INTO seen_sms_bodies (body, created_at) '
              'SELECT raw_sms, created_at FROM bank_account_transactions '
              "WHERE raw_sms IS NOT NULL AND trim(raw_sms) != ''",
            );
          }
        },
      );
}
