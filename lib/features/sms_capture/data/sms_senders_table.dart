import 'package:drift/drift.dart';

class SmsSenders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get address => text()();
  BoolColumn get isBuiltIn =>
      boolean().withDefault(const Constant(false))();
}
