import 'package:drift/drift.dart';
import 'package:spendsense/features/transactions/data/card_transactions_table.dart';

class RecoveryLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get creditTransactionId => integer().references(
        CardTransactions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get recoverableTransactionId => integer().references(
        CardTransactions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get amountPaise => integer()();
}

class RecoverablePersons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get lastUsedAt => dateTime()();
}
