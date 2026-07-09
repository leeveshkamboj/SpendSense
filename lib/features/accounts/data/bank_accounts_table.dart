import 'package:drift/drift.dart';

/// Bank account — separate from credit cards; no billing cycle fields.
class BankAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bank => text()();
  TextColumn get lastFourDigits => text().withLength(min: 4, max: 4)();
  TextColumn get nickname => text()();
  IntColumn get openingBalancePaise => integer().withDefault(const Constant(0))();
  IntColumn get colorValue => integer()();
  TextColumn get iconName => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
