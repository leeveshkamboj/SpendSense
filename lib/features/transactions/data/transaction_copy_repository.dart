import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/domain/card_transaction_copy_draft.dart';

class TransactionCopyRepository {
  TransactionCopyRepository({
    required CardTransactionRepository transactions,
    required TagRepository tags,
    required CreditCardRepository creditCards,
  })  : _transactions = transactions,
        _tags = tags,
        _creditCards = creditCards;

  final CardTransactionRepository _transactions;
  final TagRepository _tags;
  final CreditCardRepository _creditCards;

  Future<CardTransactionCopyDraft> draftFrom(int transactionId) async {
    final transaction = await _transactions.getById(transactionId);
    if (transaction == null) {
      throw StateError('Transaction not found');
    }

    final tagNames = await _tags.listForCardTransaction(transactionId);

    return CardTransactionCopyDraft(
      creditCardId: transaction.creditCardId,
      merchant: transaction.merchant,
      category: transaction.category,
      tags: tagNames,
      kind: transaction.kind,
    );
  }

  Future<int> saveCopy({
    required CardTransactionCopyDraft draft,
    required int amountPaise,
    required DateTime transactionAt,
  }) async {
    final billingCycleId = await _creditCards.findBillingCycleIdForTransaction(
      cardId: draft.creditCardId,
      transactionAt: transactionAt,
    );

    final transactionId = await _transactions.insert(
      NewCardTransaction(
        creditCardId: draft.creditCardId,
        billingCycleId: billingCycleId,
        kind: draft.kind,
        amountPaise: amountPaise,
        merchant: draft.merchant,
        category: draft.category,
        transactionAt: transactionAt,
        source: 'Manual',
      ),
    );

    if (draft.tags.isNotEmpty) {
      await _tags.setForCardTransaction(
        transactionId: transactionId,
        tagNames: draft.tags,
      );
    }

    return transactionId;
  }
}
