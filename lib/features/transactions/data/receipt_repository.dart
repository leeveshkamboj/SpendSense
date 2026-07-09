import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class ReceiptRepository {
  ReceiptRepository(this._database);

  final AppDatabase _database;

  Future<List<String>> listForTransaction(int transactionId) async {
    final rows = await (_database.select(_database.cardTransactionReceipts)
          ..where((row) => row.cardTransactionId.equals(transactionId))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
    return rows.map((row) => row.filePath).toList();
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
}
