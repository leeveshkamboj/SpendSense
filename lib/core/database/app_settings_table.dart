import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get onboardingComplete =>
      boolean().withDefault(const Constant(false))();
  IntColumn get importLastIndex =>
      integer().withDefault(const Constant(0))();
  BoolColumn get importCompleted =>
      boolean().withDefault(const Constant(false))();
}
