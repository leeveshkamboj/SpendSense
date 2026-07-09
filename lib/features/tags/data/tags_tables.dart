import 'package:drift/drift.dart';
import 'package:spendsense/features/merchants/data/merchants_table.dart';
import 'package:spendsense/features/transactions/data/card_transactions_table.dart';

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class CardTransactionTags extends Table {
  IntColumn get cardTransactionId => integer().references(
        CardTransactions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {cardTransactionId, tagId};
}

class MerchantDefaultTags extends Table {
  IntColumn get merchantId => integer().references(
        Merchants,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {merchantId, tagId};
}
