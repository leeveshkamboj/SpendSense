import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_avatar.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/card_transaction_list_tile.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';
import 'package:spendsense/features/shell/spend_sense_app_bar_actions.dart';

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
    final searchAll = ref.watch(searchAllSegmentsProvider);
    final recoverableOnly = ref.watch(recoverableFilterProvider);
    final query = ref.watch(transactionSearchQueryProvider);
    final useFullSearch = searchAll || query.trim().isNotEmpty;

    final cardGroups = useFullSearch
        ? ref.watch(filteredGroupedCardTransactionsWhenSearchingProvider)
        : ref.watch(filteredGroupedCardTransactionsProvider);
    final pendingDeletes = ref.watch(pendingCardTransactionDeletesProvider);
    final pageState = ref.watch(cardTransactionPageProvider);
    final cardsAsync = ref.watch(activeCreditCardsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const AppBrandTitle(title: 'Transactions'),
        actions: spendSenseAppBarActions(context),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'spendsense-add-transaction',
        onPressed: () => context.push('/transactions/manual'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (pageState.valueOrNull?.isCurrentCycleOnly ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Current billing cycle · tap history for full search',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transactions',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(transactionSearchQueryProvider.notifier)
                                    .state = '';
                              },
                            ),
                    ),
                    onChanged: (value) {
                      ref.read(transactionSearchQueryProvider.notifier).state =
                          value;
                    },
                  ),
                ),
                const SizedBox(width: 4),
                _CompactFilterButton(
                  tooltip: 'Search all history',
                  icon: Icons.history,
                  selected: searchAll,
                  onPressed: () {
                    ref.read(searchAllSegmentsProvider.notifier).state =
                        !searchAll;
                  },
                ),
                _CompactFilterButton(
                  tooltip: 'Recoverable only',
                  icon: Icons.people_outline,
                  selected: recoverableOnly,
                  onPressed: () {
                    ref.read(recoverableFilterProvider.notifier).state =
                        !recoverableOnly;
                  },
                ),
              ],
            ),
          ),
          _CardFilterBar(cardsAsync: cardsAsync),
          Expanded(
            child: cardGroups.when(
              data: (cycleGroups) {
                      final cards = cardsAsync.valueOrNull ?? [];
                      final nicknameById = {
                        for (final card in cards) card.id: card.nickname,
                      };
                      final colorById = {
                        for (final card in cards) card.id: card.colorValue,
                      };
                      final networkById = {
                        for (final card in cards) card.id: card.network,
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
                                      cardNetwork: networkById[
                                          visibleTransactions[index]
                                              .creditCardId],
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
                    error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactFilterButton extends StatelessWidget {
  const _CompactFilterButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        style: IconButton.styleFrom(
          backgroundColor:
              selected ? scheme.primaryContainer : Colors.transparent,
          foregroundColor:
              selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: const Text('All'),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              selected: selectedCardId == null,
              onSelected: (_) {
                ref.read(transactionCardFilterProvider.notifier).state = null;
              },
            ),
          ),
          for (final card in cards)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                avatar: CreditCardAvatar(
                  network: card.network,
                  colorValue: card.colorValue,
                  radius: 8,
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
    this.cardNetwork,
    required this.onDelete,
    required this.onEdit,
    required this.onLongPress,
  });

  final CardTransaction transaction;
  final String cardNickname;
  final int colorValue;
  final String? cardNetwork;
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
        cardNetwork: cardNetwork,
        onLongPress: onLongPress,
      ),
    );
  }
}
