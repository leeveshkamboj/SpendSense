import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/receipt_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_cycle_move_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_merge_repository.dart';
import 'package:spendsense/features/transactions/domain/grouped_bank_transactions.dart';
import 'package:spendsense/features/transactions/domain/grouped_card_transactions.dart';
import 'package:spendsense/features/transactions/engine/transaction_search.dart';

enum TransactionSegment { cards, accounts }

const cardTransactionPageSize = 20;

final transactionSegmentProvider = StateProvider<TransactionSegment>(
  (ref) => TransactionSegment.cards,
);

final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
final searchAllSegmentsProvider = StateProvider<bool>((ref) => false);
final recoverableFilterProvider = StateProvider<bool>((ref) => false);

final pendingCardTransactionDeletesProvider = StateProvider<Set<int>>(
  (ref) => {},
);

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(databaseProvider));
});

final transactionMergeRepositoryProvider =
    Provider<TransactionMergeRepository>((ref) {
  return TransactionMergeRepository(
    database: ref.watch(databaseProvider),
    transactions: ref.watch(cardTransactionRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
  );
});

final transactionCycleMoveRepositoryProvider =
    Provider<TransactionCycleMoveRepository>((ref) {
  return TransactionCycleMoveRepository(
    transactions: ref.watch(cardTransactionRepositoryProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
  );
});

class CardTransactionPageState {
  const CardTransactionPageState({
    required this.transactions,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<CardTransaction> transactions;
  final bool hasMore;
  final bool isLoadingMore;

  CardTransactionPageState copyWith({
    List<CardTransaction>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CardTransactionPageState(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CardTransactionPageNotifier
    extends StateNotifier<AsyncValue<CardTransactionPageState>> {
  CardTransactionPageNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final recoverableOnly = _ref.read(recoverableFilterProvider);
      final repository = _ref.read(cardTransactionRepositoryProvider);
      final page = await repository.listPage(
        offset: 0,
        limit: cardTransactionPageSize,
        recoverableOnly: recoverableOnly,
      );
      final total = await repository.countAll(recoverableOnly: recoverableOnly);
      state = AsyncValue.data(
        CardTransactionPageState(
          transactions: page,
          hasMore: page.length < total,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final recoverableOnly = _ref.read(recoverableFilterProvider);
      final repository = _ref.read(cardTransactionRepositoryProvider);
      final nextPage = await repository.listPage(
        offset: current.transactions.length,
        limit: cardTransactionPageSize,
        recoverableOnly: recoverableOnly,
      );
      final merged = [...current.transactions, ...nextPage];
      final total = await repository.countAll(recoverableOnly: recoverableOnly);
      state = AsyncValue.data(
        CardTransactionPageState(
          transactions: merged,
          hasMore: merged.length < total,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final cardTransactionPageProvider = StateNotifierProvider<
    CardTransactionPageNotifier, AsyncValue<CardTransactionPageState>>((ref) {
  final notifier = CardTransactionPageNotifier(ref);
  ref.listen(recoverableFilterProvider, (_, __) {
    notifier.refresh();
  });
  return notifier;
});

List<CardTransaction> filterCardTransactions({
  required List<CardTransaction> transactions,
  required String query,
}) {
  return transactions
      .where(
        (tx) => matchesCardTransactionSearch(
          merchant: tx.merchant,
          category: tx.category,
          referenceNumber: tx.referenceNumber,
          notes: tx.notes,
          query: query,
        ),
      )
      .toList();
}

final filteredGroupedCardTransactionsProvider =
    FutureProvider<List<TransactionCycleGroup>>((ref) async {
  final pageAsync = ref.watch(cardTransactionPageProvider);
  final pageState = pageAsync.valueOrNull;
  if (pageState == null) {
    return [];
  }

  final query = ref.watch(transactionSearchQueryProvider);
  final creditCards = ref.watch(creditCardRepositoryProvider);

  final filtered = filterCardTransactions(
    transactions: pageState.transactions,
    query: query,
  );

  final cyclesById = <int, BillingCycle>{};
  for (final transaction in filtered) {
    final cycleId = transaction.billingCycleId;
    if (cycleId == null || cyclesById.containsKey(cycleId)) {
      continue;
    }

    final cardCycles = await creditCards.listCycles(transaction.creditCardId);
    for (final cycle in cardCycles) {
      cyclesById[cycle.id] = cycle;
    }
  }

  return groupCardTransactionsByCycle(
    transactions: filtered,
    cyclesById: cyclesById,
  );
});

final filteredGroupedBankTransactionsProvider =
    FutureProvider<List<BankTransactionMonthGroup>>((ref) async {
  final transactions =
      await ref.watch(bankAccountTransactionsProvider.future);
  final query = ref.watch(transactionSearchQueryProvider);
  final searchAll = ref.watch(searchAllSegmentsProvider);
  final segment = ref.watch(transactionSegmentProvider);

  if (!searchAll && segment != TransactionSegment.accounts) {
    return [];
  }

  final filtered = transactions
      .where(
        (tx) => matchesBankTransactionSearch(
          merchant: tx.merchant,
          beneficiary: tx.beneficiary,
          category: tx.category,
          referenceNumber: tx.referenceNumber,
          notes: tx.notes,
          query: query,
        ),
      )
      .toList();

  return groupBankTransactionsByMonth(
    transactions: filtered,
    now: DateTime.now(),
  );
});

final filteredGroupedCardTransactionsWhenSearchingProvider =
    FutureProvider<List<TransactionCycleGroup>>((ref) async {
  final searchAll = ref.watch(searchAllSegmentsProvider);
  final segment = ref.watch(transactionSegmentProvider);
  if (!searchAll && segment != TransactionSegment.cards) {
    return [];
  }

  final query = ref.watch(transactionSearchQueryProvider);
  if (query.trim().isEmpty) {
    return ref.watch(filteredGroupedCardTransactionsProvider.future);
  }

  final repository = ref.watch(cardTransactionRepositoryProvider);
  final recoverableOnly = ref.watch(recoverableFilterProvider);
  final all = await repository.listAll(recoverableOnly: recoverableOnly);
  final creditCards = ref.watch(creditCardRepositoryProvider);
  final filtered = filterCardTransactions(transactions: all, query: query);

  final cyclesById = <int, BillingCycle>{};
  for (final transaction in filtered) {
    final cycleId = transaction.billingCycleId;
    if (cycleId == null || cyclesById.containsKey(cycleId)) {
      continue;
    }

    final cardCycles = await creditCards.listCycles(transaction.creditCardId);
    for (final cycle in cardCycles) {
      cyclesById[cycle.id] = cycle;
    }
  }

  return groupCardTransactionsByCycle(
    transactions: filtered,
    cyclesById: cyclesById,
  );
});
