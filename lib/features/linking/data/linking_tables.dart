import 'package:drift/drift.dart';
import 'package:spendsense/features/accounts/data/bank_account_transactions_table.dart';
import 'package:spendsense/features/transactions/data/card_transactions_table.dart';

class TransactionLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  IntColumn get cardTransactionId => integer()
      .references(CardTransactions, #id, onDelete: KeyAction.cascade)
      .nullable()();
  IntColumn get bankAccountTransactionId => integer()
      .references(BankAccountTransactions, #id, onDelete: KeyAction.cascade)
      .nullable()();
  IntColumn get linkedCardTransactionId => integer()
      .references(CardTransactions, #id, onDelete: KeyAction.cascade)
      .nullable()();
  IntColumn get linkedBankAccountTransactionId => integer()
      .references(BankAccountTransactions, #id, onDelete: KeyAction.cascade)
      .nullable()();
}
