import 'package:drift/drift.dart';
import 'package:spendsense/features/accounts/data/bank_accounts_table.dart';

class BankAccountTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bankAccountId =>
      integer().references(BankAccounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get merchant => text().nullable()();
  TextColumn get beneficiary => text().nullable()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get transactionAt => dateTime()();
  TextColumn get source => text()();
  TextColumn get rawSms => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  BoolColumn get isReviewed =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
