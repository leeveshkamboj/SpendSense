import 'package:drift/drift.dart';

class BudgetSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get monthlyLimitPaise => integer().nullable()();
  DateTimeColumn get currentPeriodStart => dateTime().nullable()();
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
