import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';

class NewCardTransaction {
  const NewCardTransaction({
    required this.creditCardId,
    required this.kind,
    required this.amountPaise,
    required this.merchant,
    required this.transactionAt,
    required this.source,
    this.billingCycleId,
    this.rawSms,
    this.referenceNumber,
  });

  final int creditCardId;
  final int? billingCycleId;
  final String kind;
  final int amountPaise;
  final String merchant;
  final DateTime transactionAt;
  final String source;
  final String? rawSms;
  final String? referenceNumber;
}

class CardTransactionRepository {
  CardTransactionRepository(this._database);

  final AppDatabase _database;

  Future<int> insert(NewCardTransaction transaction) {
    return _database.into(_database.cardTransactions).insert(
          CardTransactionsCompanion.insert(
            creditCardId: transaction.creditCardId,
            billingCycleId: Value(transaction.billingCycleId),
            kind: transaction.kind,
            amountPaise: transaction.amountPaise,
            merchant: transaction.merchant,
            transactionAt: transaction.transactionAt,
            source: transaction.source,
            rawSms: Value(transaction.rawSms),
            referenceNumber: Value(transaction.referenceNumber),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<CardTransaction?> getById(int id) {
    return (_database.select(_database.cardTransactions)
          ..where((tx) => tx.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<CardTransaction>> listForCard(int creditCardId) {
    return (_database.select(_database.cardTransactions)
          ..where((tx) => tx.creditCardId.equals(creditCardId))
          ..orderBy([(tx) => OrderingTerm.desc(tx.transactionAt)]))
        .get();
  }

  Future<List<CardTransaction>> listAll() {
    return (_database.select(_database.cardTransactions)
          ..orderBy([(tx) => OrderingTerm.desc(tx.transactionAt)]))
        .get();
  }

  Future<List<CapturedTransactionSnapshot>> listSnapshotsForCard(
    int creditCardId,
  ) async {
    final transactions = await listForCard(creditCardId);
    return transactions
        .map(
          (tx) => CapturedTransactionSnapshot(
            creditCardId: tx.creditCardId,
            amountPaise: tx.amountPaise,
            merchant: tx.merchant,
            transactionAt: tx.transactionAt,
            referenceNumber: tx.referenceNumber,
          ),
        )
        .toList();
  }

  Future<void> markReviewed(int transactionId) {
    return (_database.update(_database.cardTransactions)
          ..where((tx) => tx.id.equals(transactionId)))
        .write(const CardTransactionsCompanion(isReviewed: Value(true)));
  }
}
