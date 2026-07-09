import 'package:drift/drift.dart';

class Merchants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawName => text().unique()();
  TextColumn get displayName => text().nullable()();
  TextColumn get defaultCategory => text().nullable()();
  BoolColumn get isUserCustomized =>
      boolean().withDefault(const Constant(false))();
}
