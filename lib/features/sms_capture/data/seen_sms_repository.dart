import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class SeenSmsRepository {
  SeenSmsRepository(this._database);

  final AppDatabase _database;

  Future<bool> contains(String body) async {
    final normalized = body.trim();
    if (normalized.isEmpty) {
      return false;
    }
    final row = await (_database.select(_database.seenSmsBodies)
          ..where((t) => t.body.equals(normalized)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> remember(String body) async {
    final normalized = body.trim();
    if (normalized.isEmpty) {
      return;
    }
    await _database
        .into(_database.seenSmsBodies)
        .insert(
          SeenSmsBodiesCompanion.insert(
            body: normalized,
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}
