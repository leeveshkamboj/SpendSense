import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_detail_screen.dart';

class CreditCardSetupScreen extends ConsumerStatefulWidget {
  const CreditCardSetupScreen({super.key});

  @override
  ConsumerState<CreditCardSetupScreen> createState() =>
      _CreditCardSetupScreenState();
}

class _CreditCardSetupScreenState extends ConsumerState<CreditCardSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _networkController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _billDayController = TextEditingController();
  final _dueOffsetController = TextEditingController(text: '18');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _bankController.dispose();
    _lastFourController.dispose();
    _nicknameController.dispose();
    _networkController.dispose();
    _creditLimitController.dispose();
    _billDayController.dispose();
    _dueOffsetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final repository = ref.read(creditCardRepositoryProvider);
    final bank = _bankController.text.trim();
    final lastFour = _lastFourController.text.trim();
    final nickname = _nicknameController.text.trim().isEmpty
        ? '$bank ••$lastFour'
        : _nicknameController.text.trim();

    final id = await repository.create(
      NewCreditCard(
        bank: bank,
        lastFourDigits: lastFour,
        nickname: nickname,
        network: _networkController.text.trim().isEmpty
            ? null
            : _networkController.text.trim(),
        creditLimitPaise: _parseOptionalRupees(_creditLimitController.text),
        colorValue: 0xFF00695C,
        iconName: 'credit_card',
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );

    final billDay = int.tryParse(_billDayController.text.trim());
    final dueOffset = int.tryParse(_dueOffsetController.text.trim());
    if (billDay != null && dueOffset != null) {
      final now = DateTime.now();
      await repository.configureBilling(
        cardId: id,
        billDayOfMonth: billDay,
        dueDateOffsetDays: dueOffset,
        historyFrom: DateTime(now.year - 1, now.month, now.day),
        historyTo: now,
      );
    }

    ref.invalidate(creditCardsProvider);
    if (!mounted) return;
    context.go('/accounts/cards/$id');
  }

  int? _parseOptionalRupees(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final rupees = double.tryParse(trimmed);
    if (rupees == null) return null;
    return (rupees * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add credit card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _bankController,
              decoration: const InputDecoration(labelText: 'Bank'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _lastFourController,
              decoration: const InputDecoration(labelText: 'Last 4 digits'),
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) =>
                  value == null || value.length != 4 ? 'Enter 4 digits' : null,
            ),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname (optional)',
              ),
            ),
            TextFormField(
              controller: _networkController,
              decoration: const InputDecoration(
                labelText: 'Network (Visa, Mastercard, RuPay, Amex)',
              ),
            ),
            TextFormField(
              controller: _creditLimitController,
              decoration: const InputDecoration(labelText: 'Credit limit (₹)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _billDayController,
              decoration: const InputDecoration(
                labelText: 'Bill date (day of month)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _dueOffsetController,
              decoration: const InputDecoration(
                labelText: 'Due date offset (days after bill)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save card'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCardConfigureScreen extends ConsumerStatefulWidget {
  const CreditCardConfigureScreen({required this.cardId, super.key});

  final int cardId;

  @override
  ConsumerState<CreditCardConfigureScreen> createState() =>
      _CreditCardConfigureScreenState();
}

class _CreditCardConfigureScreenState
    extends ConsumerState<CreditCardConfigureScreen> {
  final _billDayController = TextEditingController();
  final _dueOffsetController = TextEditingController(text: '18');

  @override
  void dispose() {
    _billDayController.dispose();
    _dueOffsetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final billDay = int.tryParse(_billDayController.text.trim());
    final dueOffset = int.tryParse(_dueOffsetController.text.trim());
    if (billDay == null || dueOffset == null) return;

    final repository = ref.read(creditCardRepositoryProvider);
    final now = DateTime.now();
    await repository.configureBilling(
      cardId: widget.cardId,
      billDayOfMonth: billDay,
      dueDateOffsetDays: dueOffset,
      historyFrom: DateTime(now.year - 1, now.month, now.day),
      historyTo: now,
    );

    ref.invalidate(creditCardProvider(widget.cardId));
    ref.invalidate(billingCyclesProvider(widget.cardId));
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure billing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _billDayController,
              decoration: const InputDecoration(
                labelText: 'Bill date (day of month)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _dueOffsetController,
              decoration: const InputDecoration(
                labelText: 'Due date offset (days after bill)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save billing settings'),
            ),
          ],
        ),
      ),
    );
  }
}
