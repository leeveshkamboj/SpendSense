import 'package:spendsense/core/database/database.dart';

class AppDataRepository {
  AppDataRepository(this._database);

  final AppDatabase _database;

  static const _tableNames = [
    'transaction_links',
    'card_transaction_tags',
    'merchant_default_tags',
    'card_transaction_receipts',
    'recovery_links',
    'budget_alert_crossings',
    'card_transactions',
    'bank_account_transactions',
    'billing_cycles',
    'category_budgets',
    'budget_settings',
    'recoverable_persons',
    'credit_cards',
    'bank_accounts',
    'merchants',
    'categories',
    'tags',
    'sms_senders',
    'app_settings',
  ];

  Future<void> deleteAllData() async {
    await _database.customStatement('PRAGMA foreign_keys = OFF');
    for (final table in _tableNames) {
      await _database.customStatement('DELETE FROM $table');
    }
    await _database.customStatement('PRAGMA foreign_keys = ON');
  }
}
