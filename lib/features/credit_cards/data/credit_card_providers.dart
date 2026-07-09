import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';

final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  return CreditCardRepository(ref.watch(databaseProvider));
});

final activeCreditCardsProvider = FutureProvider((ref) {
  return ref.watch(creditCardRepositoryProvider).listActive();
});
