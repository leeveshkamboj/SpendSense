import 'package:drift/drift.dart';

/// SMS bodies already handled (captured, duplicate, or user-deleted).
///
/// Inbox sync re-scans a lookback window; without this, deleting a transaction
/// lets the same SMS be captured again.
class SeenSmsBodies extends Table {
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {body};
}
