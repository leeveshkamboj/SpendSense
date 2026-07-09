import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final recoverableRepositoryProvider = Provider<RecoverableRepository>((ref) {
  return RecoverableRepository(
    database: ref.watch(databaseProvider),
    transactions: ref.watch(cardTransactionRepositoryProvider),
  );
});

final recoverableSummaryProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(recoverableRepositoryProvider).summaryByPerson();
});
