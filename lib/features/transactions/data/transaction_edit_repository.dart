import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class TransactionEditRepository {
  TransactionEditRepository({
    required CardTransactionRepository transactions,
    required CreditCardRepository creditCards,
  })  : _transactions = transactions,
        _creditCards = creditCards;

  final CardTransactionRepository _transactions;
  final CreditCardRepository _creditCards;

  Future<void> update({
    required int transactionId,
    required int amountPaise,
    required String merchant,
    required String? category,
    required DateTime transactionAt,
  }) async {
    final transaction = await _transactions.getById(transactionId);
    if (transaction == null) {
      throw StateError('Transaction not found');
    }

    final billingCycleId = await _creditCards.findBillingCycleIdForTransaction(
      cardId: transaction.creditCardId,
      transactionAt: transactionAt,
    );

    await _transactions.update(
      transactionId: transactionId,
      amountPaise: amountPaise,
      merchant: merchant,
      category: category,
      transactionAt: transactionAt,
      billingCycleId: billingCycleId,
    );
  }
}
