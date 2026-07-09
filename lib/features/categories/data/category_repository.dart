import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/categories/domain/default_categories.dart';
import 'package:spendsense/features/merchants/engine/merchant_dictionary.dart';

class CategoryRepository {
  CategoryRepository(this._database);

  final AppDatabase _database;

  Future<void> ensureDefaults() async {
    final existing = await listNames();
    if (existing.isNotEmpty) return;

    await _database.batch((batch) {
      for (final name in defaultCategories) {
        batch.insert(
          _database.categories,
          CategoriesCompanion.insert(
            name: name,
            isBuiltIn: const Value(true),
          ),
        );
      }
    });
  }

  Future<List<String>> listNames() async {
    final rows = await (_database.select(_database.categories)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    return rows.map((row) => row.name).toList();
  }

  Future<void> rename({required String from, required String to}) async {
    await (_database.update(_database.categories)
          ..where((row) => row.name.equals(from)))
        .write(CategoriesCompanion(name: Value(to)));

    await _reassignTransactions(from: from, to: to);
    await _reassignCategoryBudgets(from: from, to: to);
  }

  Future<void> delete(String name) async {
    if (name == miscellaneousCategory) {
      throw ArgumentError('Cannot delete Miscellaneous');
    }

    await (_database.delete(_database.categories)
          ..where((row) => row.name.equals(name)))
        .go();

    await _reassignTransactions(from: name, to: miscellaneousCategory);
    await _reassignCategoryBudgets(from: name, to: miscellaneousCategory);
  }

  Future<void> _reassignTransactions({
    required String from,
    required String to,
  }) async {
    await (_database.update(_database.cardTransactions)
          ..where((tx) => tx.category.equals(from)))
        .write(CardTransactionsCompanion(category: Value(to)));

    await (_database.update(_database.bankAccountTransactions)
          ..where((tx) => tx.category.equals(from)))
        .write(BankAccountTransactionsCompanion(category: Value(to)));
  }

  Future<void> _reassignCategoryBudgets({
    required String from,
    required String to,
  }) async {
    await (_database.update(_database.categoryBudgets)
          ..where((row) => row.category.equals(from)))
        .write(CategoryBudgetsCompanion(category: Value(to)));
  }
}
