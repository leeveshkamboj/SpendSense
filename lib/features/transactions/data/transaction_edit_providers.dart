import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/transaction_edit_repository.dart';

final transactionEditRepositoryProvider = Provider<TransactionEditRepository>((
  ref,
) {
  return TransactionEditRepository(
    transactions: ref.watch(cardTransactionRepositoryProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
  );
});
