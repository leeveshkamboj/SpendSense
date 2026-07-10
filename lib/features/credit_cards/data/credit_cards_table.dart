import 'package:drift/drift.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pools_table.dart';

class CreditCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bank => text()();
  TextColumn get lastFourDigits => text().withLength(min: 4, max: 4)();
  TextColumn get nickname => text()();
  TextColumn get network => text().nullable()();
  IntColumn get creditLimitPaise => integer().nullable()();
  IntColumn get creditLimitPoolId =>
      integer().nullable().references(CreditLimitPools, #id)();
  IntColumn get billDayOfMonth => integer().nullable()();
  IntColumn get dueDateOffsetDays => integer().nullable()();
  IntColumn get colorValue => integer()();
  TextColumn get iconName => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
