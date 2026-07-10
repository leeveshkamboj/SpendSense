import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';
import 'package:spendsense/features/transactions/domain/grouped_card_transactions.dart';

final cardTransactionRepositoryProvider = Provider<CardTransactionRepository>((
  ref,
) {
  return CardTransactionRepository(ref.watch(databaseProvider));
});

final cardTransactionsProvider = FutureProvider<List<CardTransaction>>((ref) {
  return ref.watch(cardTransactionRepositoryProvider).listAll();
});

final groupedCardTransactionsProvider =
    FutureProvider<List<TransactionCycleGroup>>((ref) async {
  final transactions = await ref.watch(cardTransactionsProvider.future);
  final creditCards = ref.watch(creditCardRepositoryProvider);
  final cards = await creditCards.listActive();
  final nicknameByCardId = {for (final card in cards) card.id: card.nickname};
  final currentCycles = await creditCards.listCurrentCycles();
  final currentCycleIds = currentCycles.map((cycle) => cycle.id).toSet();
  final cyclesById = <int, BillingCycle>{
    for (final cycle in currentCycles) cycle.id: cycle,
  };

  for (final transaction in transactions) {
    final cycleId = transaction.billingCycleId;
    if (cycleId == null || cyclesById.containsKey(cycleId)) {
      continue;
    }

    final cycle = await creditCards.findCycleById(cycleId);
    if (cycle != null) {
      cyclesById[cycleId] = cycle;
    }
  }

  return groupCardTransactionsByCycle(
    transactions: transactions,
    cyclesById: cyclesById,
    nicknameByCardId: nicknameByCardId,
    currentCycleIds: currentCycleIds,
  );
});
