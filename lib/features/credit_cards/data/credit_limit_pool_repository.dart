import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class NewCreditLimitPool {
  const NewCreditLimitPool({
    required this.name,
    required this.creditLimitPaise,
  });

  final String name;
  final int creditLimitPaise;
}

class CreditLimitPoolRepository {
  CreditLimitPoolRepository(this._database);

  final AppDatabase _database;

  Future<int> create(NewCreditLimitPool pool) {
    return _database.into(_database.creditLimitPools).insert(
          CreditLimitPoolsCompanion.insert(
            name: pool.name.trim(),
            creditLimitPaise: pool.creditLimitPaise,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> update({
    required int poolId,
    required String name,
    required int creditLimitPaise,
  }) {
    return (_database.update(_database.creditLimitPools)
          ..where((pool) => pool.id.equals(poolId)))
        .write(
      CreditLimitPoolsCompanion(
        name: Value(name.trim()),
        creditLimitPaise: Value(creditLimitPaise),
      ),
    );
  }

  Future<void> delete(int poolId) async {
    await (_database.update(_database.creditCards)
          ..where((card) => card.creditLimitPoolId.equals(poolId)))
        .write(const CreditCardsCompanion(creditLimitPoolId: Value(null)));
    await (_database.delete(_database.creditLimitPools)
          ..where((pool) => pool.id.equals(poolId)))
        .go();
  }

  Future<CreditLimitPool?> getById(int poolId) {
    return (_database.select(_database.creditLimitPools)
          ..where((pool) => pool.id.equals(poolId)))
        .getSingleOrNull();
  }

  Future<List<CreditLimitPool>> listAll() {
    return (_database.select(_database.creditLimitPools)
          ..orderBy([(pool) => OrderingTerm.asc(pool.name)]))
        .get();
  }

  Future<List<CreditCard>> listCardsInPool(int poolId) {
    return (_database.select(_database.creditCards)
          ..where((card) => card.creditLimitPoolId.equals(poolId))
          ..orderBy([(card) => OrderingTerm.asc(card.nickname)]))
        .get();
  }

  Future<void> setCardsInPool({
    required int poolId,
    required Set<int> cardIds,
  }) async {
    final currentlyLinked = await listCardsInPool(poolId);
    final currentIds = currentlyLinked.map((card) => card.id).toSet();

    for (final cardId in currentIds.difference(cardIds)) {
      await (_database.update(_database.creditCards)
            ..where((card) => card.id.equals(cardId)))
          .write(const CreditCardsCompanion(creditLimitPoolId: Value(null)));
    }

    for (final cardId in cardIds.difference(currentIds)) {
      await (_database.update(_database.creditCards)
            ..where((card) => card.id.equals(cardId)))
          .write(
        CreditCardsCompanion(
          creditLimitPoolId: Value(poolId),
          creditLimitPaise: const Value(null),
        ),
      );
    }
  }
}
