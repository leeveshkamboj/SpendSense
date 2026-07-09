import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';

class NewBankAccountTransaction {
  const NewBankAccountTransaction({
    required this.bankAccountId,
    required this.kind,
    required this.amountPaise,
    required this.transactionAt,
    required this.source,
    this.merchant,
    this.beneficiary,
    this.category,
    this.rawSms,
    this.referenceNumber,
  });

  final int bankAccountId;
  final String kind;
  final int amountPaise;
  final DateTime transactionAt;
  final String source;
  final String? merchant;
  final String? beneficiary;
  final String? category;
  final String? rawSms;
  final String? referenceNumber;
}

class BankAccountTransactionRepository {
  BankAccountTransactionRepository(this._database);

  final AppDatabase _database;

  Future<int> insert(NewBankAccountTransaction transaction) {
    return _database.into(_database.bankAccountTransactions).insert(
          BankAccountTransactionsCompanion.insert(
            bankAccountId: transaction.bankAccountId,
            kind: transaction.kind,
            amountPaise: transaction.amountPaise,
            merchant: Value(transaction.merchant),
            beneficiary: Value(transaction.beneficiary),
            category: Value(transaction.category),
            transactionAt: transaction.transactionAt,
            source: transaction.source,
            rawSms: Value(transaction.rawSms),
            referenceNumber: Value(transaction.referenceNumber),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<BankAccountTransaction>> listAll() {
    return (_database.select(_database.bankAccountTransactions)
          ..orderBy([(row) => OrderingTerm.desc(row.transactionAt)]))
        .get();
  }

  Future<List<BankAccountTransaction>> listForAccount(int bankAccountId) {
    return (_database.select(_database.bankAccountTransactions)
          ..where((row) => row.bankAccountId.equals(bankAccountId))
          ..orderBy([(row) => OrderingTerm.desc(row.transactionAt)]))
        .get();
  }

  Future<List<CapturedTransactionSnapshot>> listSnapshotsForAccount(
    int bankAccountId,
  ) async {
    final transactions = await listForAccount(bankAccountId);
    return transactions
        .map(
          (tx) => CapturedTransactionSnapshot(
            bankAccountId: tx.bankAccountId,
            amountPaise: tx.amountPaise,
            merchant: tx.merchant ?? tx.beneficiary ?? 'Unknown',
            transactionAt: tx.transactionAt,
            referenceNumber: tx.referenceNumber,
          ),
        )
        .toList();
  }

  Future<void> markReviewed(int transactionId) {
    return (_database.update(_database.bankAccountTransactions)
          ..where((row) => row.id.equals(transactionId)))
        .write(
      const BankAccountTransactionsCompanion(isReviewed: Value(true)),
    );
  }
}
