import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class TagRepository {
  TagRepository(this._database);

  final AppDatabase _database;

  Future<void> setForCardTransaction({
    required int transactionId,
    required List<String> tagNames,
  }) async {
    final normalized = tagNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    await _database.transaction(() async {
      await (_database.delete(_database.cardTransactionTags)
            ..where((row) => row.cardTransactionId.equals(transactionId)))
          .go();

      for (final name in normalized) {
        final tagId = await _ensureTag(name);
        await _database.into(_database.cardTransactionTags).insert(
              CardTransactionTagsCompanion.insert(
                cardTransactionId: transactionId,
                tagId: tagId,
              ),
            );
      }
    });
  }

  Future<List<String>> listForCardTransaction(int transactionId) async {
    final query = _database.select(_database.tags).join([
      innerJoin(
        _database.cardTransactionTags,
        _database.cardTransactionTags.tagId.equalsExp(_database.tags.id),
      ),
    ])
      ..where(
        _database.cardTransactionTags.cardTransactionId.equals(transactionId),
      )
      ..orderBy([OrderingTerm.asc(_database.tags.name)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(_database.tags).name).toList();
  }

  Future<int> _ensureTag(String name) async {
    final existing = await (_database.select(_database.tags)
          ..where((row) => row.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    return _database.into(_database.tags).insert(
          TagsCompanion.insert(name: name),
        );
  }
}
