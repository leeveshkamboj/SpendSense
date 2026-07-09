import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/merchants/engine/merchant_dictionary.dart';

class MerchantRecord {
  const MerchantRecord({
    required this.id,
    required this.rawName,
    this.displayName,
    this.defaultCategory,
    required this.isUserCustomized,
  });

  final int id;
  final String rawName;
  final String? displayName;
  final String? defaultCategory;
  final bool isUserCustomized;
}

class MerchantRepository {
  MerchantRepository(this._database);

  final AppDatabase _database;

  Future<int> ensureFromTransaction({required String rawName}) async {
    final existing = await _findByRawName(rawName);
    if (existing != null) return existing.id;

    return _database.into(_database.merchants).insert(
          MerchantsCompanion.insert(rawName: rawName),
        );
  }

  Future<String> resolveDefaultCategory(String rawName) async {
    await ensureFromTransaction(rawName: rawName);
    final merchant = await _findByRawName(rawName);
    if (merchant == null) {
      return lookupMerchantCategory(rawName);
    }

    if (merchant.isUserCustomized && merchant.defaultCategory != null) {
      return merchant.defaultCategory!;
    }

    return lookupMerchantCategory(rawName);
  }

  Future<void> updateDefaults({
    required String rawName,
    String? displayName,
    String? defaultCategory,
    List<String>? tagNames,
  }) async {
    await ensureFromTransaction(rawName: rawName);
    await (_database.update(_database.merchants)
          ..where((row) => row.rawName.equals(rawName)))
        .write(
      MerchantsCompanion(
        displayName: displayName == null
            ? const Value.absent()
            : Value(displayName),
        defaultCategory: defaultCategory == null
            ? const Value.absent()
            : Value(defaultCategory),
        isUserCustomized: const Value(true),
      ),
    );

    if (tagNames != null) {
      await _setDefaultTags(rawName: rawName, tagNames: tagNames);
    }
  }

  Future<List<String>> resolveDefaultTags(String rawName) async {
    final merchant = await _findByRawName(rawName);
    if (merchant == null || !merchant.isUserCustomized) {
      return const [];
    }

    return _listDefaultTags(merchant.id);
  }

  Future<List<MerchantRecord>> listAll() async {
    final rows = await (_database.select(_database.merchants)
          ..orderBy([(row) => OrderingTerm.asc(row.rawName)]))
        .get();

    return rows
        .map(
          (row) => MerchantRecord(
            id: row.id,
            rawName: row.rawName,
            displayName: row.displayName,
            defaultCategory: row.defaultCategory,
            isUserCustomized: row.isUserCustomized,
          ),
        )
        .toList();
  }

  Future<Merchant?> _findByRawName(String rawName) {
    return (_database.select(_database.merchants)
          ..where((row) => row.rawName.equals(rawName)))
        .getSingleOrNull();
  }

  Future<void> _setDefaultTags({
    required String rawName,
    required List<String> tagNames,
  }) async {
    final merchant = await _findByRawName(rawName);
    if (merchant == null) return;

    final normalized = tagNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    await _database.transaction(() async {
      await (_database.delete(_database.merchantDefaultTags)
            ..where((row) => row.merchantId.equals(merchant.id)))
          .go();

      for (final name in normalized) {
        final tagId = await _ensureTag(name);
        await _database.into(_database.merchantDefaultTags).insert(
              MerchantDefaultTagsCompanion.insert(
                merchantId: merchant.id,
                tagId: tagId,
              ),
            );
      }
    });
  }

  Future<List<String>> _listDefaultTags(int merchantId) async {
    final query = _database.select(_database.tags).join([
      innerJoin(
        _database.merchantDefaultTags,
        _database.merchantDefaultTags.tagId.equalsExp(_database.tags.id),
      ),
    ])
      ..where(_database.merchantDefaultTags.merchantId.equals(merchantId))
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
