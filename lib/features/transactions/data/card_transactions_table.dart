import 'package:drift/drift.dart';
import 'package:spendsense/features/billing_cycles/data/billing_cycles_table.dart';
import 'package:spendsense/features/credit_cards/data/credit_cards_table.dart';

class CardTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get creditCardId =>
      integer().references(CreditCards, #id, onDelete: KeyAction.cascade)();
  IntColumn get billingCycleId =>
      integer().references(BillingCycles, #id).nullable()();
  TextColumn get kind => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get merchant => text()();
  DateTimeColumn get transactionAt => dateTime()();
  TextColumn get source => text()();
  TextColumn get rawSms => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  BoolColumn get isReviewed =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
