import 'package:drift/drift.dart';

class BudgetSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get monthlyLimitPaise => integer().nullable()();
  DateTimeColumn get currentPeriodStart => dateTime().nullable()();
  IntColumn get alertThreshold75 =>
      integer().withDefault(const Constant(75))();
  IntColumn get alertThreshold90 =>
      integer().withDefault(const Constant(90))();
  IntColumn get alertThreshold100 =>
      integer().withDefault(const Constant(100))();
}

class CategoryBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  IntColumn get limitPaise => integer()();
}

class BudgetAlertCrossings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get budgetKey => text()();
  TextColumn get threshold => text()();
  DateTimeColumn get periodStart => dateTime()();
}
