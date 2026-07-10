import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_repository.dart';

final creditLimitPoolRepositoryProvider = Provider<CreditLimitPoolRepository>((ref) {
  return CreditLimitPoolRepository(ref.watch(databaseProvider));
});

final creditLimitPoolsProvider = FutureProvider<List<CreditLimitPool>>((ref) {
  return ref.watch(creditLimitPoolRepositoryProvider).listAll();
});

final creditLimitPoolProvider =
    FutureProvider.family<CreditLimitPool?, int>((ref, poolId) {
  return ref.watch(creditLimitPoolRepositoryProvider).getById(poolId);
});

final cardsInCreditLimitPoolProvider =
    FutureProvider.family<List<CreditCard>, int>((ref, poolId) {
  return ref.watch(creditLimitPoolRepositoryProvider).listCardsInPool(poolId);
});
