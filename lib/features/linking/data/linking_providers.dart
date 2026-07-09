import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/linking/data/linking_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final linkingRepositoryProvider = Provider<LinkingRepository>((ref) {
  return LinkingRepository(
    database: ref.watch(databaseProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
  );
});
