import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class TransactionReceipt {
  const TransactionReceipt({
    required this.id,
    required this.filePath,
    required this.createdAt,
  });

  final int id;
  final String filePath;
  final DateTime createdAt;
}

class ReceiptRepository {
  ReceiptRepository(this._database);

  final AppDatabase _database;

  Future<List<TransactionReceipt>> listReceiptsForTransaction(
    int transactionId,
  ) async {
    final rows = await (_database.select(_database.cardTransactionReceipts)
          ..where((row) => row.cardTransactionId.equals(transactionId))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();

    return rows
        .map(
          (row) => TransactionReceipt(
            id: row.id,
            filePath: row.filePath,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<void> add({
    required int transactionId,
    required String filePath,
  }) async {
    await _database.into(_database.cardTransactionReceipts).insert(
          CardTransactionReceiptsCompanion.insert(
            cardTransactionId: transactionId,
            filePath: filePath,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> remove(int receiptId) async {
    await (_database.delete(_database.cardTransactionReceipts)
          ..where((row) => row.id.equals(receiptId)))
        .go();
  }

  Future<Set<int>> listTransactionIdsWithReceipts() async {
    final rows = await _database.select(_database.cardTransactionReceipts).get();
    return rows.map((row) => row.cardTransactionId).toSet();
  }
}
