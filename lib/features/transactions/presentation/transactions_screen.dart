import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
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
          Expanded(
            child: segment == TransactionSegment.accounts
                ? _AccountsSegmentBody(searchAll: searchAll, query: query)
                : cardGroups.when(
                    data: (cycleGroups) {
                      if (cycleGroups.isEmpty) {
                        return const Center(
                          child: Text('No card transactions yet'),
                        );
                      }

                      final slivers = <Widget>[];
                      for (final group in cycleGroups) {
                        slivers.add(
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyHeaderDelegate(group.cycleLabel),
                          ),
                        );
                        slivers.add(
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final transaction = group.transactions[index];
                                if (pendingDeletes.contains(transaction.id)) {
                                  return const SizedBox.shrink();
                                }
                                return _CardTransactionTile(
                                  transaction: transaction,
                                  onDelete: () => _scheduleDelete(transaction),
                                  onEdit: () => context.push(
                                    '/transactions/${transaction.id}/edit',
                                  ),
                                  onLongPress: () =>
                                      _showCardTransactionActions(
                                    context,
                                    transaction,
                                  ),
                                );
                              },
                              childCount: group.transactions.length,
                            ),
                          ),
                        );
                      }

                      if (pageState.valueOrNull?.isLoadingMore ?? false) {
                        slivers.add(
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        );
                      }

                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: slivers,
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

class _CardTransactionTile extends StatelessWidget {
  const _CardTransactionTile({
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
    required this.onLongPress,
  });

  final CardTransaction transaction;
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
      child: ListTile(
        title: Text(transaction.merchant),
        subtitle: Text(formatPaise(transaction.amountPaise)),
        trailing: transaction.isRecoverable
            ? const Icon(Icons.people_outline, size: 18)
            : transaction.isReviewed
                ? null
                : const Icon(Icons.fiber_new, size: 16),
        onTap: () => context.push('/transactions/${transaction.id}'),
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
                delegate: _StickyHeaderDelegate(group.header),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = group.transactions[index];
                    return ListTile(
                      title: Text(
                        transaction.beneficiary ??
                            transaction.merchant ??
                            transaction.category ??
                            'Transaction',
                      ),
                      subtitle: Text(formatPaise(transaction.amountPaise)),
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
  _StickyHeaderDelegate(this.label);

  final String label;

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.label != label;
  }
}
