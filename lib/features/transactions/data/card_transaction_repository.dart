import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';

class NewCardTransaction {
  const NewCardTransaction({
    required this.creditCardId,
    required this.amountPaise,
    required this.merchant,
    required this.transactionAt,
    required this.source,
    this.kind = 'expense',
    this.billingCycleId,
    this.rawSms,
    this.referenceNumber,
    this.category,
    this.notes,
    this.location,
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
  final String? category;
  final String? notes;
  final String? location;
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
            category: Value(transaction.category),
            notes: Value(transaction.notes),
            location: Value(transaction.location),
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

  Future<List<CardTransaction>> listForBillingCycle(int billingCycleId) {
    return (_database.select(_database.cardTransactions)
          ..where((tx) => tx.billingCycleId.equals(billingCycleId)))
        .get();
  }

  Future<List<CardTransaction>> listAll({
    bool recoverableOnly = false,
  }) {
    final query = _database.select(_database.cardTransactions);
    if (recoverableOnly) {
      query.where((tx) => tx.isRecoverable.equals(true));
    }
    query.orderBy([(tx) => OrderingTerm.desc(tx.transactionAt)]);
    return query.get();
  }

  Future<List<CardTransaction>> listPage({
    required int offset,
    required int limit,
    bool recoverableOnly = false,
  }) {
    final query = _database.select(_database.cardTransactions);
    if (recoverableOnly) {
      query.where((tx) => tx.isRecoverable.equals(true));
    }
    query
      ..orderBy([(tx) => OrderingTerm.desc(tx.transactionAt)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Future<int> countAll({bool recoverableOnly = false}) async {
    final expression = _database.cardTransactions.id.count();
    final query = _database.selectOnly(_database.cardTransactions)
      ..addColumns([expression]);
    if (recoverableOnly) {
      query.where(_database.cardTransactions.isRecoverable.equals(true));
    }
    final row = await query.getSingle();
    return row.read(expression) ?? 0;
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

  Future<void> delete(int transactionId) {
    return (_database.delete(_database.cardTransactions)
          ..where((tx) => tx.id.equals(transactionId)))
        .go();
  }

  Future<void> update({
    required int transactionId,
    required int amountPaise,
    required String merchant,
    required String? category,
    required DateTime transactionAt,
    required int? billingCycleId,
  }) async {
    final existing = await getById(transactionId);
    return updateDetails(
      transactionId: transactionId,
      amountPaise: amountPaise,
      merchant: merchant,
      category: category,
      transactionAt: transactionAt,
      billingCycleId: billingCycleId,
      notes: existing?.notes,
      location: existing?.location,
      referenceNumber: existing?.referenceNumber,
    );
  }

  Future<void> updateDetails({
    required int transactionId,
    required int amountPaise,
    required String merchant,
    required String? category,
    required DateTime transactionAt,
    required int? billingCycleId,
    String? notes,
    String? location,
    String? referenceNumber,
  }) {
    return (_database.update(_database.cardTransactions)
          ..where((tx) => tx.id.equals(transactionId)))
        .write(
      CardTransactionsCompanion(
        amountPaise: Value(amountPaise),
        merchant: Value(merchant),
        category: Value(category),
        transactionAt: Value(transactionAt),
        billingCycleId: Value(billingCycleId),
        notes: Value(notes),
        location: Value(location),
        referenceNumber: Value(referenceNumber),
      ),
    );
  }
}
