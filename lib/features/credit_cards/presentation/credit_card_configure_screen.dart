import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_providers.dart';
import 'package:spendsense/features/credit_cards/domain/card_network.dart';
import 'package:spendsense/features/credit_cards/presentation/card_network_picker.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_detail_screen.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class CreditCardConfigureScreen extends ConsumerStatefulWidget {
  const CreditCardConfigureScreen({required this.cardId, super.key});

  final int cardId;

  @override
  ConsumerState<CreditCardConfigureScreen> createState() =>
      _CreditCardConfigureScreenState();
}

class _CreditCardConfigureScreenState
    extends ConsumerState<CreditCardConfigureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _creditLimitController = TextEditingController();
  final _billDayController = TextEditingController();
  final _dueOffsetController = TextEditingController(text: '18');
  var _initialized = false;
  _CreditLimitMode _limitMode = _CreditLimitMode.none;
  int? _selectedPoolId;
  CardNetwork? _selectedNetwork;

  @override
  void dispose() {
    _creditLimitController.dispose();
    _billDayController.dispose();
    _dueOffsetController.dispose();
    super.dispose();
  }

  void _initializeFromCard(CreditCard card) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    if (card.billDayOfMonth != null) {
      _billDayController.text = card.billDayOfMonth.toString();
    }
    if (card.dueDateOffsetDays != null) {
      _dueOffsetController.text = card.dueDateOffsetDays.toString();
    }
    if (card.creditLimitPoolId != null) {
      _limitMode = _CreditLimitMode.shared;
      _selectedPoolId = card.creditLimitPoolId;
    } else if (card.creditLimitPaise != null) {
      _limitMode = _CreditLimitMode.individual;
      _creditLimitController.text = (card.creditLimitPaise! / 100).toString();
    } else {
      _limitMode = _CreditLimitMode.none;
    }
    _selectedNetwork = CardNetwork.parse(card.network);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final billDay = int.parse(_billDayController.text.trim());
    final dueOffset = int.parse(_dueOffsetController.text.trim());

    final repository = ref.read(creditCardRepositoryProvider);
    final now = DateTime.now();
    final historyMonths =
        await ref.read(onboardingRepositoryProvider).smsImportWindowMonths();
    await repository.updateBillingSettings(
      cardId: widget.cardId,
      billDayOfMonth: billDay,
      dueDateOffsetDays: dueOffset,
      historyFrom: billingHistoryStart(now: now, months: historyMonths),
      historyTo: now,
    );

    switch (_limitMode) {
      case _CreditLimitMode.individual:
        await repository.updateCreditLimit(
          cardId: widget.cardId,
          creditLimitPaise: _parseOptionalRupees(_creditLimitController.text),
        );
      case _CreditLimitMode.shared:
        if (_selectedPoolId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select a shared limit pool')),
            );
          }
          return;
        }
        await repository.assignCreditLimitPool(
          cardId: widget.cardId,
          creditLimitPoolId: _selectedPoolId,
        );
      case _CreditLimitMode.none:
        await repository.clearCreditLimitSettings(cardId: widget.cardId);
    }

    await repository.updateNetwork(
      cardId: widget.cardId,
      network: _selectedNetwork?.storageValue,
    );

    ref.invalidate(creditCardsProvider);
    ref.invalidate(creditLimitPoolsProvider);
    ref.invalidate(creditCardProvider(widget.cardId));
    ref.invalidate(billingCyclesProvider(widget.cardId));
    ref.invalidate(billingCycleSummariesProvider(widget.cardId));
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(filteredGroupedCardTransactionsWhenSearchingProvider);
    ref.invalidate(unpaidBillsProvider);
    invalidateDashboardAndWidgets(ref);
    if (!mounted) return;
    context.pop();
  }

  int? _parseOptionalRupees(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final rupees = double.tryParse(trimmed);
    if (rupees == null) return null;
    return (rupees * 100).round();
  }

  String? _validateBillDay(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 1 || parsed > 31) {
      return 'Enter a day between 1 and 31';
    }
    return null;
  }

  String? _validateDueOffset(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0 || parsed > 60) {
      return 'Enter days between 0 and 60';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cardAsync = ref.watch(creditCardProvider(widget.cardId));
    final poolsAsync = ref.watch(creditLimitPoolsProvider);
    final historyMonths =
        ref.watch(smsImportWindowMonthsProvider).valueOrNull ??
            defaultSmsImportWindowMonths;

    return Scaffold(
      appBar: AppBar(title: const Text('Card settings')),
      body: cardAsync.when(
        data: (card) {
          if (card == null) {
            return const Center(child: Text('Card not found'));
          }

          _initializeFromCard(card);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  card.nickname,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.bank} ••${card.lastFourDigits}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                CardNetworkPicker(
                  value: _selectedNetwork,
                  onChanged: (value) => setState(() => _selectedNetwork = value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Credit limit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioListTile<_CreditLimitMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Individual limit'),
                  subtitle: const Text('This card has its own credit limit'),
                  value: _CreditLimitMode.individual,
                  groupValue: _limitMode,
                  onChanged: (value) => setState(() => _limitMode = value!),
                ),
                if (_limitMode == _CreditLimitMode.individual)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: TextFormField(
                      controller: _creditLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Credit limit (₹)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                RadioListTile<_CreditLimitMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shared limit'),
                  subtitle: const Text('Use a pool shared with other cards'),
                  value: _CreditLimitMode.shared,
                  groupValue: _limitMode,
                  onChanged: (value) => setState(() => _limitMode = value!),
                ),
                if (_limitMode == _CreditLimitMode.shared)
                  poolsAsync.when(
                    data: (pools) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedPoolId,
                            decoration: const InputDecoration(
                              labelText: 'Shared limit pool',
                            ),
                            items: [
                              for (final pool in pools)
                                DropdownMenuItem(
                                  value: pool.id,
                                  child: Text(pool.name),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedPoolId = value),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () =>
                                context.push('/accounts/shared-limits'),
                            child: const Text('Manage shared limits'),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error loading pools: $error'),
                    ),
                  ),
                RadioListTile<_CreditLimitMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Not set'),
                  value: _CreditLimitMode.none,
                  groupValue: _limitMode,
                  onChanged: (value) => setState(() => _limitMode = value!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Changing the bill date will reassign transactions to the '
                  'matching billing cycles for the last $historyMonths months.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _billDayController,
                  decoration: const InputDecoration(
                    labelText: 'Bill date (day of month)',
                    helperText: 'Day your statement closes each month',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateBillDay,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dueOffsetController,
                  decoration: const InputDecoration(
                    labelText: 'Due date offset (days after bill)',
                    helperText: 'Days after bill date until payment is due',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateDueOffset,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save card settings'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

enum _CreditLimitMode {
  individual,
  shared,
  none,
}
