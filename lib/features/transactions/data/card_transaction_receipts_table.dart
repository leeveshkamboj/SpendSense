import 'package:drift/drift.dart';
import 'package:spendsense/features/transactions/data/card_transactions_table.dart';

class CardTransactionReceipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardTransactionId => integer().references(
        CardTransactions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime()();
}
