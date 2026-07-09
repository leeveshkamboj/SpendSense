import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/transaction_copy_repository.dart';

final transactionCopyRepositoryProvider = Provider<TransactionCopyRepository>((
  ref,
) {
  return TransactionCopyRepository(
    transactions: ref.watch(cardTransactionRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
  );
});
