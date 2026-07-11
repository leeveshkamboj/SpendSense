import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/receipt_providers.dart';
import 'package:spendsense/features/transactions/data/transaction_cycle_move_repository.dart';
import 'package:spendsense/features/transactions/data/transaction_merge_repository.dart';
import 'package:spendsense/features/transactions/domain/grouped_card_transactions.dart';
import 'package:spendsense/features/transactions/domain/transaction_cycle_filter.dart';
import 'package:spendsense/features/transactions/domain/transaction_filters.dart';
import 'package:spendsense/features/transactions/engine/transaction_search.dart';

const cardTransactionPageSize = 20;

final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
final searchAllSegmentsProvider = StateProvider<bool>((ref) => false);
final recoverableFilterProvider = StateProvider<bool>((ref) => false);
final recurringFilterProvider = StateProvider<bool>((ref) => false);
final transactionCardFilterProvider = StateProvider<int?>((ref) => null);
final transactionFiltersProvider =
    StateProvider<TransactionFilters>((ref) => const TransactionFilters());

final transactionIdsWithReceiptsProvider = FutureProvider<Set<int>>((ref) {
  return ref.watch(receiptRepositoryProvider).listTransactionIdsWithReceipts();
});

final pendingCardTransactionDeletesProvider = StateProvider<Set<int>>(
  (ref) => {},
);

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
    required this.isCurrentCycleOnly,
  });

  final List<CardTransaction> transactions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isCurrentCycleOnly;

  CardTransactionPageState copyWith({
    List<CardTransaction>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isCurrentCycleOnly,
  }) {
    return CardTransactionPageState(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isCurrentCycleOnly: isCurrentCycleOnly ?? this.isCurrentCycleOnly,
    );
  }
}

class CardTransactionPageNotifier
    extends StateNotifier<AsyncValue<CardTransactionPageState>> {
  CardTransactionPageNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;

  bool get _usesExpandedHistory {
    final searchAll = _ref.read(searchAllSegmentsProvider);
    final query = _ref.read(transactionSearchQueryProvider);
    final filters = _ref.read(transactionFiltersProvider);
    return searchAll || query.trim().isNotEmpty || filters.hasNonCycleFilters;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final recoverableOnly = _ref.read(recoverableFilterProvider);
      final repository = _ref.read(cardTransactionRepositoryProvider);
      final filters = _ref.read(transactionFiltersProvider);
      final historyMonths =
          await _ref.read(onboardingRepositoryProvider).smsImportWindowMonths();
      final creditCards = _ref.read(creditCardRepositoryProvider);
      final currentCycles = await creditCards.listCurrentCycles();
      final allCycles = await creditCards.listCyclesForActiveCards();
      final allowedCycleIds = resolveTransactionCycleIds(
        filter: filters.cycleFilter,
        currentCycles: currentCycles,
        allCycles: allCycles,
      );

      if (_usesExpandedHistory) {
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
            isCurrentCycleOnly: false,
          ),
        );
        return;
      }

      final cycleTransactions = await repository.listForBillingCycleIds(
        allowedCycleIds.toList(),
        recoverableOnly: recoverableOnly,
      );
      var transactions = cycleTransactions;
      if (filters.isCurrentCycle) {
        final unassigned = await repository.listUnassignedSince(
          since: billingHistoryStart(months: historyMonths),
          recoverableOnly: recoverableOnly,
        );
        transactions = _mergeTransactions(cycleTransactions, unassigned);
      }

      state = AsyncValue.data(
        CardTransactionPageState(
          transactions: transactions,
          hasMore: false,
          isLoadingMore: false,
          isCurrentCycleOnly: filters.isCurrentCycle,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    if (_usesExpandedHistory) {
      await _loadMoreHistory();
    }
  }

  Future<void> _loadMoreHistory() async {
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
          isCurrentCycleOnly: false,
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
  ref.listen(searchAllSegmentsProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen(transactionSearchQueryProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen(transactionFiltersProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen(recurringFilterProvider, (_, __) {
    notifier.refresh();
  });
  return notifier;
});

List<CardTransaction> _mergeTransactions(
  List<CardTransaction> cycleTransactions,
  List<CardTransaction> unassigned,
) {
  final byId = <int, CardTransaction>{
    for (final transaction in cycleTransactions) transaction.id: transaction,
    for (final transaction in unassigned) transaction.id: transaction,
  };
  return byId.values.toList()
    ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));
}

List<CardTransaction> filterCardTransactions({
  required List<CardTransaction> transactions,
  required String query,
  int? cardId,
  bool currentCycleOnly = false,
  Set<int>? currentCycleIds,
  Set<int>? allowedBillingCycleIds,
  TransactionFilters filters = const TransactionFilters(),
  Set<int> transactionIdsWithReceipts = const {},
  bool recurringOnly = false,
}) {
  var filtered = transactions
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

  if (recurringOnly) {
    filtered = filtered.where((tx) => tx.isRecurring).toList();
  }

  if (!filters.isEmpty || allowedBillingCycleIds != null) {
    filtered = filtered
        .where(
          (tx) => matchesTransactionFilters(
            transaction: tx,
            filters: filters,
            transactionIdsWithReceipts: transactionIdsWithReceipts,
            allowedBillingCycleIds: allowedBillingCycleIds,
          ),
        )
        .toList();
  }

  if (cardId != null) {
    filtered = filtered.where((tx) => tx.creditCardId == cardId).toList();
  }

  if (currentCycleOnly) {
    final cycleIds = currentCycleIds ?? const {};
    filtered = filtered
        .where(
          (tx) =>
              tx.billingCycleId == null ||
              cycleIds.contains(tx.billingCycleId),
        )
        .toList();
  }

  return filtered;
}

Future<List<TransactionCycleGroup>> _buildCycleGroups({
  required Ref ref,
  required List<CardTransaction> transactions,
}) async {
  final creditCards = ref.read(creditCardRepositoryProvider);
  final cards = await creditCards.listActive();
  final nicknameByCardId = {for (final card in cards) card.id: card.nickname};
  final currentCycles = await creditCards.listCurrentCycles();
  final currentCycleIds = currentCycles.map((cycle) => cycle.id).toSet();

  final cyclesById = <int, BillingCycle>{};
  for (final cycle in currentCycles) {
    cyclesById[cycle.id] = cycle;
  }

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
}

final filteredGroupedCardTransactionsProvider =
    FutureProvider<List<TransactionCycleGroup>>((ref) async {
  final pageAsync = ref.watch(cardTransactionPageProvider);
  final pageState = pageAsync.valueOrNull;
  if (pageState == null) {
    return [];
  }

  final query = ref.watch(transactionSearchQueryProvider);
  final cardId = ref.watch(transactionCardFilterProvider);
  final filters = ref.watch(transactionFiltersProvider);
  final recurringOnly = ref.watch(recurringFilterProvider);
  final receiptIds = await ref.watch(transactionIdsWithReceiptsProvider.future);
  final creditCards = ref.read(creditCardRepositoryProvider);
  final currentCycles = await creditCards.listCurrentCycles();
  final currentCycleIds = currentCycles.map((cycle) => cycle.id).toSet();
  final allCycles = await creditCards.listCyclesForActiveCards();
  final allowedCycleIds = resolveTransactionCycleIds(
    filter: filters.cycleFilter,
    currentCycles: currentCycles,
    allCycles: allCycles,
  );
  final filtered = filterCardTransactions(
    transactions: pageState.transactions,
    query: query,
    cardId: cardId,
    currentCycleOnly: pageState.isCurrentCycleOnly,
    currentCycleIds: currentCycleIds,
    allowedBillingCycleIds:
        pageState.isCurrentCycleOnly ? null : allowedCycleIds,
    filters: filters,
    transactionIdsWithReceipts: receiptIds,
    recurringOnly: recurringOnly,
  );

  return _buildCycleGroups(ref: ref, transactions: filtered);
});

final filteredGroupedCardTransactionsWhenSearchingProvider =
    FutureProvider<List<TransactionCycleGroup>>((ref) async {
  final query = ref.watch(transactionSearchQueryProvider);
  if (query.trim().isEmpty) {
    return ref.watch(filteredGroupedCardTransactionsProvider.future);
  }

  final repository = ref.watch(cardTransactionRepositoryProvider);
  final recoverableOnly = ref.watch(recoverableFilterProvider);
  final recurringOnly = ref.watch(recurringFilterProvider);
  final cardId = ref.watch(transactionCardFilterProvider);
  final filters = ref.watch(transactionFiltersProvider);
  final receiptIds = await ref.watch(transactionIdsWithReceiptsProvider.future);
  final creditCards = ref.read(creditCardRepositoryProvider);
  final currentCycles = await creditCards.listCurrentCycles();
  final allCycles = await creditCards.listCyclesForActiveCards();
  final allowedCycleIds = resolveTransactionCycleIds(
    filter: filters.cycleFilter,
    currentCycles: currentCycles,
    allCycles: allCycles,
  );
  final all = await repository.listAll(recoverableOnly: recoverableOnly);
  final filtered = filterCardTransactions(
    transactions: all,
    query: query,
    cardId: cardId,
    allowedBillingCycleIds: allowedCycleIds,
    filters: filters,
    transactionIdsWithReceipts: receiptIds,
    recurringOnly: recurringOnly,
  );

  return _buildCycleGroups(ref: ref, transactions: filtered);
});
