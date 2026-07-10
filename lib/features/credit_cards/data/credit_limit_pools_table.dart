import 'package:drift/drift.dart';

class CreditLimitPools extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get creditLimitPaise => integer()();
  DateTimeColumn get createdAt => dateTime()();
}
