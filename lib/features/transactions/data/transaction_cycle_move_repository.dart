import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class TransactionCycleMoveRepository {
  TransactionCycleMoveRepository({
    required CardTransactionRepository transactions,
    required CreditCardRepository creditCards,
  })  : _transactions = transactions,
        _creditCards = creditCards;

  final CardTransactionRepository _transactions;
  final CreditCardRepository _creditCards;

  Future<void> moveToCycle({
    required int transactionId,
    required int targetCycleId,
  }) async {
    final transaction = await _transactions.getById(transactionId);
    if (transaction == null) {
      throw StateError('Transaction not found');
    }

    final cycles = await _creditCards.listCycles(transaction.creditCardId);
    final targetCycle = cycles.where((cycle) => cycle.id == targetCycleId);
    if (targetCycle.isEmpty) {
      throw ArgumentError('Target cycle does not belong to this card');
    }

    await _transactions.updateDetails(
      transactionId: transactionId,
      amountPaise: transaction.amountPaise,
      merchant: transaction.merchant,
      category: transaction.category,
      transactionAt: transaction.transactionAt,
      billingCycleId: targetCycleId,
      notes: transaction.notes,
      location: transaction.location,
      referenceNumber: transaction.referenceNumber,
    );
  }
}
