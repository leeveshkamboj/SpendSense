import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/formatting/transaction_amount_display.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/transactions/presentation/card_transaction_list_tile.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _pendingDeleteTimers = <int, Timer>{};
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    for (final timer in _pendingDeleteTimers.values) {
      timer.cancel();
    }
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(cardTransactionPageProvider.notifier).loadMore();
    }
  }

  void _scheduleDelete(CardTransaction transaction) {
    final pending = {
      ...ref.read(pendingCardTransactionDeletesProvider),
      transaction.id,
    };
    ref.read(pendingCardTransactionDeletesProvider.notifier).state = pending;

    _pendingDeleteTimers[transaction.id]?.cancel();
    _pendingDeleteTimers[transaction.id] = Timer(
      const Duration(seconds: 4),
      () => _finalizeDelete(transaction.id),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undoDelete(transaction.id),
        ),
      ),
    );
  }

  Future<void> _finalizeDelete(int transactionId) async {
    _pendingDeleteTimers.remove(transactionId)?.cancel();

    final pending = {...ref.read(pendingCardTransactionDeletesProvider)};
    pending.remove(transactionId);
    ref.read(pendingCardTransactionDeletesProvider.notifier).state = pending;

    await ref.read(cardTransactionRepositoryProvider).delete(transactionId);
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(filteredGroupedCardTransactionsWhenSearchingProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);
    invalidateDashboardAndWidgets(ref);
  }

  void _undoDelete(int transactionId) {
    _pendingDeleteTimers.remove(transactionId)?.cancel();

    final pending = {...ref.read(pendingCardTransactionDeletesProvider)};
    pending.remove(transactionId);
    ref.read(pendingCardTransactionDeletesProvider.notifier).state = pending;
  }

  void _showCardTransactionActions(
    BuildContext context,
    CardTransaction transaction,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/transactions/copy/${transaction.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.call_split),
                title: const Text('Split'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/transactions/${transaction.id}/split');
                },
              ),
              ListTile(
                leading: const Icon(Icons.merge),
                title: const Text('Merge'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/transactions/${transaction.id}/merge');
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Cycle move'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/transactions/${transaction.id}/cycle-move');
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Mark recoverable'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/transactions/${transaction.id}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final segment = ref.watch(transactionSegmentProvider);
    final searchAll = ref.watch(searchAllSegmentsProvider);
    final query = ref.watch(transactionSearchQueryProvider);
    final useFullSearch = searchAll || query.trim().isNotEmpty;

    final cardGroups = useFullSearch
        ? ref.watch(filteredGroupedCardTransactionsWhenSearchingProvider)
        : ref.watch(filteredGroupedCardTransactionsProvider);
    final pendingDeletes = ref.watch(pendingCardTransactionDeletesProvider);
    final pageState = ref.watch(cardTransactionPageProvider);
    final cardsAsync = ref.watch(activeCreditCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<TransactionSegment>(
              segments: const [
                ButtonSegment(
                  value: TransactionSegment.cards,
                  label: Text('Cards'),
                ),
                ButtonSegment(
                  value: TransactionSegment.accounts,
                  label: Text('Accounts'),
                ),
              ],
              selected: {segment},
              onSelectionChanged: (selection) {
                ref.read(transactionSegmentProvider.notifier).state =
                    selection.first;
              },
            ),
          ),
        ),
      ),
      floatingActionButton: segment == TransactionSegment.cards
          ? FloatingActionButton(
              onPressed: () => context.push('/transactions/manual'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          if (pageState.valueOrNull?.isCurrentCycleOnly ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing current billing cycle and recent imports. Enable Search all for full history.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(transactionSearchQueryProvider.notifier).state =
                              '';
                        },
                      ),
              ),
              onChanged: (value) {
                ref.read(transactionSearchQueryProvider.notifier).state =
                    value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Search all'),
                  selected: searchAll,
                  onSelected: (selected) {
                    ref.read(searchAllSegmentsProvider.notifier).state =
                        selected;
                  },
                ),
                if (segment == TransactionSegment.cards) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Recoverable'),
                    selected: ref.watch(recoverableFilterProvider),
                    onSelected: (selected) {
                      ref.read(recoverableFilterProvider.notifier).state =
                          selected;
                    },
                  ),
                ],
              ],
            ),
          ),
          if (segment == TransactionSegment.cards)
            _CardFilterBar(cardsAsync: cardsAsync),
          Expanded(
            child: segment == TransactionSegment.accounts
                ? _AccountsSegmentBody(searchAll: searchAll, query: query)
                : cardGroups.when(
                    data: (cycleGroups) {
                      final cards = cardsAsync.valueOrNull ?? [];
                      final nicknameById = {
                        for (final card in cards) card.id: card.nickname,
                      };
                      final colorById = {
                        for (final card in cards) card.id: card.colorValue,
                      };

                      final transactions = [
                        for (final group in cycleGroups) ...group.transactions,
                      ]..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

                      if (transactions.isEmpty) {
                        final cardFilter = ref.watch(transactionCardFilterProvider);
                        final hasConfiguredCards = cards.any(
                          (card) => card.billDayOfMonth != null,
                        );
                        final message = cardFilter != null
                            ? 'No transactions for this card'
                            : hasConfiguredCards
                                ? 'No transactions in the current billing cycle'
                                : 'Configure billing on your cards in Accounts';
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      final visibleTransactions = transactions
                          .where((tx) => !pendingDeletes.contains(tx.id))
                          .toList();

                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Card(
                              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (var index = 0;
                                      index < visibleTransactions.length;
                                      index++) ...[
                                    if (index > 0)
                                      const Divider(
                                        height: 1,
                                        indent: 72,
                                        endIndent: 16,
                                      ),
                                    _CardTransactionTile(
                                      transaction: visibleTransactions[index],
                                      cardNickname: nicknameById[
                                              visibleTransactions[index]
                                                  .creditCardId] ??
                                          'Card ${visibleTransactions[index].creditCardId}',
                                      colorValue: colorById[
                                              visibleTransactions[index]
                                                  .creditCardId] ??
                                          0xFF9E9E9E,
                                      onDelete: () => _scheduleDelete(
                                        visibleTransactions[index],
                                      ),
                                      onEdit: () => context.push(
                                        '/transactions/${visibleTransactions[index].id}/edit',
                                      ),
                                      onLongPress: () =>
                                          _showCardTransactionActions(
                                        context,
                                        visibleTransactions[index],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (pageState.valueOrNull?.isLoadingMore ?? false)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        Center(child: Text('Error: $error')),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardFilterBar extends ConsumerWidget {
  const _CardFilterBar({required this.cardsAsync});

  final AsyncValue<List<CreditCard>> cardsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = cardsAsync.valueOrNull ?? [];
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedCardId = ref.watch(transactionCardFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All cards'),
              selected: selectedCardId == null,
              onSelected: (_) {
                ref.read(transactionCardFilterProvider.notifier).state = null;
              },
            ),
          ),
          for (final card in cards)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: CircleAvatar(
                  radius: 10,
                  backgroundColor:
                      Color(card.colorValue).withValues(alpha: 0.2),
                  child: Icon(
                    Icons.credit_card,
                    size: 12,
                    color: Color(card.colorValue),
                  ),
                ),
                label: Text(card.nickname),
                selected: selectedCardId == card.id,
                onSelected: (selected) {
                  ref.read(transactionCardFilterProvider.notifier).state =
                      selected ? card.id : null;
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CardTransactionTile extends StatelessWidget {
  const _CardTransactionTile({
    required this.transaction,
    required this.cardNickname,
    required this.colorValue,
    required this.onDelete,
    required this.onEdit,
    required this.onLongPress,
  });

  final CardTransaction transaction;
  final String cardNickname;
  final int colorValue;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        onDelete();
        return true;
      },
      child: CardTransactionListTile(
        transaction: transaction,
        cardNickname: cardNickname,
        colorValue: colorValue,
        onLongPress: onLongPress,
      ),
    );
  }
}

class _AccountsSegmentBody extends ConsumerWidget {
  const _AccountsSegmentBody({
    required this.searchAll,
    required this.query,
  });

  final bool searchAll;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = (searchAll || query.trim().isNotEmpty)
        ? ref.watch(filteredGroupedBankTransactionsProvider)
        : ref.watch(groupedBankTransactionsProvider);

    return groups.when(
      data: (monthGroups) {
        if (monthGroups.isEmpty) {
          return const Center(child: Text('No bank account transactions yet'));
        }

        return CustomScrollView(
          slivers: [
            for (final group in monthGroups) ...[
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  title: group.header,
                  subtitle: '${group.transactions.length} transactions',
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = group.transactions[index];
                    final scheme = Theme.of(context).colorScheme;
                    final direction =
                        bankTransactionDirection(transaction.kind);
                    final amountColor =
                        transactionDirectionColor(scheme, direction);
                    final title = transaction.beneficiary ??
                        transaction.merchant ??
                        transaction.category ??
                        'Transaction';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text(
                        transactionDirectionLabel(direction),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      trailing: Text(
                        formatSignedPaise(transaction.amountPaise, direction),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: amountColor,
                            ),
                      ),
                    );
                  },
                  childCount: group.transactions.length,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String? badge;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (badge != null)
              Chip(
                label: Text(badge!),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.subtitle != subtitle ||
        oldDelegate.badge != badge;
  }
}
