import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/engine/transaction_merge.dart';

class TransactionMergeRepository {
  TransactionMergeRepository({
    required AppDatabase database,
    required CardTransactionRepository transactions,
    required TagRepository tags,
  })  : _database = database,
        _transactions = transactions,
        _tags = tags;

  final AppDatabase _database;
  final CardTransactionRepository _transactions;
  final TagRepository _tags;

  Future<int> merge({
    required int survivorTransactionId,
    required int duplicateTransactionId,
  }) async {
    final survivor = await _transactions.getById(survivorTransactionId);
    final duplicate = await _transactions.getById(duplicateTransactionId);
    if (survivor == null || duplicate == null) {
      throw StateError('Transaction not found');
    }
    if (survivor.creditCardId != duplicate.creditCardId) {
      throw ArgumentError('Transactions must be on the same card');
    }

    final survivorTags = await _tags.listForCardTransaction(survivor.id);
    final duplicateTags = await _tags.listForCardTransaction(duplicate.id);
    final mergedTagNames = {...survivorTags, ...duplicateTags}.toList()..sort();

    await _database.transaction(() async {
      await _transactions.updateDetails(
        transactionId: survivor.id,
        amountPaise: mergedAmountPaise(
          survivorAmountPaise: survivor.amountPaise,
          duplicateAmountPaise: duplicate.amountPaise,
        ),
        merchant: survivor.merchant,
        category: survivor.category,
        transactionAt: survivor.transactionAt,
        billingCycleId: survivor.billingCycleId,
        notes: mergedNotes(
          survivorNotes: survivor.notes,
          duplicateNotes: duplicate.notes,
        ),
        location: survivor.location ?? duplicate.location,
        referenceNumber: survivor.referenceNumber ?? duplicate.referenceNumber,
      );

      await _transactions.delete(duplicate.id);

      if (mergedTagNames.isNotEmpty) {
        await _tags.setForCardTransaction(
          transactionId: survivor.id,
          tagNames: mergedTagNames,
        );
      }
    });

    return survivor.id;
  }
}
