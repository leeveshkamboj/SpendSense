import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_repository.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';

class SharedCreditLimitFormScreen extends ConsumerStatefulWidget {
  const SharedCreditLimitFormScreen({this.poolId, super.key});

  final int? poolId;

  @override
  ConsumerState<SharedCreditLimitFormScreen> createState() =>
      _SharedCreditLimitFormScreenState();
}

class _SharedCreditLimitFormScreenState
    extends ConsumerState<SharedCreditLimitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _selectedCardIds = <int>{};
  var _initialized = false;

  bool get _isEditing => widget.poolId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _initialize(CreditLimitPool pool, List<CreditCard> linkedCards) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _nameController.text = pool.name;
    _limitController.text = (pool.creditLimitPaise / 100).toString();
    _selectedCardIds
      ..clear()
      ..addAll(linkedCards.map((card) => card.id));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final limitPaise = _parseRupees(_limitController.text);
    if (limitPaise == null) {
      return;
    }

    final repository = ref.read(creditLimitPoolRepositoryProvider);
    final poolId = widget.poolId ??
        await repository.create(
          NewCreditLimitPool(
            name: _nameController.text.trim(),
            creditLimitPaise: limitPaise,
          ),
        );

    if (_isEditing) {
      await repository.update(
        poolId: poolId,
        name: _nameController.text.trim(),
        creditLimitPaise: limitPaise,
      );
    }

    await repository.setCardsInPool(
      poolId: poolId,
      cardIds: _selectedCardIds,
    );

    _invalidate();
    if (!mounted) {
      return;
    }
    context.pop();
  }

  Future<void> _delete() async {
    final poolId = widget.poolId;
    if (poolId == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete shared limit?'),
        content: const Text(
          'Linked cards will keep their transactions, but this shared pool '
          'will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(creditLimitPoolRepositoryProvider).delete(poolId);
    _invalidate();
    if (!mounted) {
      return;
    }
    context.pop();
  }

  void _invalidate() {
    ref.invalidate(creditLimitPoolsProvider);
    if (widget.poolId != null) {
      ref.invalidate(creditLimitPoolProvider(widget.poolId!));
      ref.invalidate(cardsInCreditLimitPoolProvider(widget.poolId!));
    }
    ref.invalidate(creditCardsProvider);
    ref.invalidate(activeCreditCardsProvider);
    invalidateDashboardAndWidgets(ref);
  }

  int? _parseRupees(String value) {
    final rupees = double.tryParse(value.trim());
    if (rupees == null || rupees <= 0) {
      return null;
    }
    return (rupees * 100).round();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a pool name';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    if (_parseRupees(value ?? '') == null) {
      return 'Enter a valid limit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final poolAsync = ref.watch(creditLimitPoolProvider(widget.poolId!));
      final cardsAsync =
          ref.watch(cardsInCreditLimitPoolProvider(widget.poolId!));
      final allCardsAsync = ref.watch(creditCardsProvider);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit shared limit'),
          actions: [
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: poolAsync.when(
          data: (pool) {
            if (pool == null) {
              return const Center(child: Text('Shared limit not found'));
            }

            return cardsAsync.when(
              data: (linkedCards) => allCardsAsync.when(
                data: (allCards) {
                  _initialize(pool, linkedCards);
                  return _buildForm(allCards);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      );
    }

    final allCardsAsync = ref.watch(creditCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('New shared limit')),
      body: allCardsAsync.when(
        data: (allCards) => _buildForm(allCards),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(List<CreditCard> allCards) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Cards in the same pool share one total credit limit. Spend on '
            'any linked card counts toward that limit.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Pool name',
              helperText: 'e.g. HDFC shared limit',
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _limitController,
            decoration: const InputDecoration(
              labelText: 'Shared credit limit (₹)',
            ),
            keyboardType: TextInputType.number,
            validator: _validateLimit,
          ),
          const SizedBox(height: 16),
          Text(
            'Linked cards',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (allCards.isEmpty)
            Text(
              'Add credit cards first',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            for (final card in allCards)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(card.nickname),
                subtitle: Text('${card.bank} ••${card.lastFourDigits}'),
                value: _selectedCardIds.contains(card.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      _selectedCardIds.add(card.id);
                    } else {
                      _selectedCardIds.remove(card.id);
                    }
                  });
                },
              ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(_isEditing ? 'Save shared limit' : 'Create shared limit'),
          ),
        ],
      ),
    );
  }
}
