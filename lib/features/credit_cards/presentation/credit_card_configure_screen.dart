import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_detail_screen.dart';
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
  final _billDayController = TextEditingController();
  final _dueOffsetController = TextEditingController(text: '18');
  var _initialized = false;

  @override
  void dispose() {
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
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final billDay = int.parse(_billDayController.text.trim());
    final dueOffset = int.parse(_dueOffsetController.text.trim());

    final repository = ref.read(creditCardRepositoryProvider);
    final now = DateTime.now();
    await repository.updateBillingSettings(
      cardId: widget.cardId,
      billDayOfMonth: billDay,
      dueDateOffsetDays: dueOffset,
      historyFrom: billingHistoryStart(now: now),
      historyTo: now,
    );

    ref.invalidate(creditCardsProvider);
    ref.invalidate(creditCardProvider(widget.cardId));
    ref.invalidate(billingCyclesProvider(widget.cardId));
    ref.invalidate(billingCycleSummariesProvider(widget.cardId));
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(filteredGroupedCardTransactionsWhenSearchingProvider);
    ref.invalidate(unpaidBillsProvider);
    if (!mounted) return;
    context.pop();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Billing settings')),
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
                Text(
                  'Changing the bill date will reassign transactions to the '
                  'matching billing cycles for the last $billingHistoryMonths months.',
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
                  child: const Text('Save billing settings'),
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
