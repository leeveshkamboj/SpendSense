import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/recoverables/domain/recoverable_expense.dart';
import 'package:spendsense/features/recoverables/domain/recovery_link.dart';
import 'package:spendsense/features/recoverables/engine/recoverable_outstanding.dart';
import 'package:spendsense/features/recoverables/engine/recovery_linking.dart';
import 'package:spendsense/features/recoverables/engine/transaction_split.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class RecoverableRepository {
  RecoverableRepository({
    required AppDatabase database,
    required CardTransactionRepository transactions,
  })  : _database = database,
        _transactions = transactions;

  final AppDatabase _database;
  final CardTransactionRepository _transactions;

  Future<void> markRecoverable({
    required int transactionId,
    required bool isRecoverable,
    String? person,
  }) async {
    if (isRecoverable && (person == null || person.trim().isEmpty)) {
      throw ArgumentError('Person is required for recoverable expenses');
    }

    await (_database.update(_database.cardTransactions)
          ..where((tx) => tx.id.equals(transactionId)))
        .write(
      CardTransactionsCompanion(
        isRecoverable: Value(isRecoverable),
        recoverablePerson: Value(isRecoverable ? person!.trim() : null),
      ),
    );

    if (isRecoverable) {
      await rememberPerson(person!.trim());
    }
  }

  Future<void> splitTransaction({
    required int transactionId,
    required int personalAmountPaise,
    required int recoverableAmountPaise,
    required String person,
  }) async {
    final original = await _transactions.getById(transactionId);
    if (original == null) {
      throw StateError('Transaction not found');
    }

    validateSplitAmounts(
      originalAmountPaise: original.amountPaise,
      personalAmountPaise: personalAmountPaise,
      recoverableAmountPaise: recoverableAmountPaise,
    );

    await _database.transaction(() async {
      await (_database.delete(_database.cardTransactions)
            ..where((tx) => tx.id.equals(transactionId)))
          .go();

      await _transactions.insert(
        NewCardTransaction(
          creditCardId: original.creditCardId,
          billingCycleId: original.billingCycleId,
          kind: original.kind,
          amountPaise: personalAmountPaise,
          merchant: original.merchant,
          transactionAt: original.transactionAt,
          source: original.source,
          rawSms: original.rawSms,
          referenceNumber: original.referenceNumber,
        ),
      );

      final recoverableId = await _transactions.insert(
        NewCardTransaction(
          creditCardId: original.creditCardId,
          billingCycleId: original.billingCycleId,
          kind: original.kind,
          amountPaise: recoverableAmountPaise,
          merchant: original.merchant,
          transactionAt: original.transactionAt,
          source: original.source,
          rawSms: original.rawSms,
          referenceNumber: original.referenceNumber,
        ),
      );

      await markRecoverable(
        transactionId: recoverableId,
        isRecoverable: true,
        person: person,
      );
    });
  }

  Future<void> linkRecovery({
    required int creditTransactionId,
    required int recoverableTransactionId,
    required int amountPaise,
  }) async {
    final recoverableTx = await _transactions.getById(recoverableTransactionId);
    if (recoverableTx == null || !recoverableTx.isRecoverable) {
      throw ArgumentError('Recoverable transaction not found');
    }

    final expense = RecoverableExpense(
      transactionId: recoverableTransactionId,
      person: recoverableTx.recoverablePerson ?? 'Unknown',
      amountPaise: recoverableTx.amountPaise,
    );
    final existing = await listRecoveryAllocationsForRecoverable(recoverableTransactionId);

    validateRecoveryLink(
      expense: expense,
      existingRecoveries: existing,
      newLinkAmountPaise: amountPaise,
    );

    await _database.into(_database.recoveryLinks).insert(
          RecoveryLinksCompanion.insert(
            creditTransactionId: creditTransactionId,
            recoverableTransactionId: recoverableTransactionId,
            amountPaise: amountPaise,
          ),
        );
  }

  Future<List<RecoveryAllocation>> listRecoveryAllocationsForRecoverable(int transactionId) async {
    final rows = await (_database.select(_database.recoveryLinks)
          ..where((link) => link.recoverableTransactionId.equals(transactionId)))
        .get();

    return rows
        .map(
          (row) => RecoveryAllocation(
            creditTransactionId: row.creditTransactionId,
            recoverableTransactionId: row.recoverableTransactionId,
            amountPaise: row.amountPaise,
          ),
        )
        .toList();
  }

  Future<List<RecoveryAllocation>> listAllRecoveryAllocations() async {
    final rows = await _database.select(_database.recoveryLinks).get();
    return rows
        .map(
          (row) => RecoveryAllocation(
            creditTransactionId: row.creditTransactionId,
            recoverableTransactionId: row.recoverableTransactionId,
            amountPaise: row.amountPaise,
          ),
        )
        .toList();
  }

  Future<List<RecoverableExpense>> listRecoverableExpenses({
    int? billingCycleId,
  }) async {
    final rows = await (_database.select(_database.cardTransactions)
          ..where(
            (tx) {
              final base =
                  tx.isRecoverable.equals(true) & tx.kind.equals('expense');
              if (billingCycleId == null) {
                return base;
              }
              return base & tx.billingCycleId.equals(billingCycleId);
            },
          ))
        .get();
    return rows
        .map(
          (tx) => RecoverableExpense(
            transactionId: tx.id,
            person: tx.recoverablePerson ?? 'Unknown',
            amountPaise: tx.amountPaise,
          ),
        )
        .toList();
  }

  Future<Map<String, int>> summaryByPerson({int? billingCycleId}) async {
    final expenses = await listRecoverableExpenses(billingCycleId: billingCycleId);
    final recoveries = await listAllRecoveryAllocations();
    return summarizeRecoverablesByPerson(
      expenses: expenses,
      recoveries: recoveries,
    );
  }

  Future<int> unsettledRecoverablePaiseForCycle(int billingCycleId) async {
    final expenses = await listRecoverableExpenses(billingCycleId: billingCycleId);
    final recoveries = await listAllRecoveryAllocations();
    return totalUnsettledRecoverablePaise(
      expenses: expenses,
      recoveries: recoveries,
    );
  }

  Future<List<String>> listPersonNames({String? query}) async {
    final rows = await (_database.select(_database.recoverablePersons)
          ..orderBy([(row) => OrderingTerm.desc(row.lastUsedAt)]))
        .get();

    final names = rows.map((row) => row.name).toList();
    if (query == null || query.trim().isEmpty) {
      return names;
    }

    final normalized = query.toLowerCase();
    return names
        .where((name) => name.toLowerCase().contains(normalized))
        .toList();
  }

  Future<void> rememberPerson(String person) async {
    final existing = await (_database.select(_database.recoverablePersons)
          ..where((row) => row.name.equals(person)))
        .getSingleOrNull();

    if (existing == null) {
      await _database.into(_database.recoverablePersons).insert(
            RecoverablePersonsCompanion.insert(
              name: person,
              lastUsedAt: DateTime.now(),
            ),
          );
      return;
    }

    await (_database.update(_database.recoverablePersons)
          ..where((row) => row.id.equals(existing.id)))
        .write(RecoverablePersonsCompanion(lastUsedAt: Value(DateTime.now())));
  }
}
