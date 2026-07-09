import 'package:drift/drift.dart';
import 'package:spendsense/features/credit_cards/data/credit_cards_table.dart';

class BillingCycles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get creditCardId =>
      integer().references(CreditCards, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get billGenerated =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get paymentsAppliedPaise =>
      integer().withDefault(const Constant(0))();
}
