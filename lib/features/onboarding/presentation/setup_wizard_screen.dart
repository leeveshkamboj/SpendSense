import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/budgets/presentation/budget_settings_screen.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_configure_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_setup_screen.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';

final setupCreditCardsProvider = FutureProvider<List<CreditCard>>((ref) {
  return ref.watch(creditCardRepositoryProvider).listActive();
});

final setupBankAccountsProvider = FutureProvider<List<BankAccount>>((ref) {
  return ref.watch(bankAccountRepositoryProvider).listActive();
});

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditCards = ref.watch(setupCreditCardsProvider);
    final bankAccounts = ref.watch(setupBankAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'We found these accounts from your SMS. '
            'Configure billing for each credit card before continuing.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Credit cards',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          creditCards.when(
            data: (cards) {
              if (cards.isEmpty) {
                return const _DetectedEmptyCard(
                  message: 'No credit cards detected yet.',
                );
              }

              return Column(
                children: [
                  for (final card in cards)
                    _DetectedCreditCardTile(
                      card: card,
                      onConfigure: () => _openCardConfigure(context, ref, card.id),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Bank accounts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          bankAccounts.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const _DetectedEmptyCard(
                  message: 'No bank accounts detected from SMS.',
                );
              }

              return Column(
                children: [
                  for (final account in accounts)
                    _DetectedBankAccountTile(account: account),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreditCardSetupScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add another credit card'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BudgetSettingsScreen(),
                ),
              );
            },
            child: const Text('Set monthly budget (optional)'),
          ),
          const SizedBox(height: 8),
          creditCards.when(
            data: (cards) {
              final hasConfiguredCard =
                  cards.any((card) => card.billDayOfMonth != null);

              return FilledButton(
                onPressed: hasConfiguredCard
                    ? () => _finishOnboarding(ref)
                    : null,
                child: const Text('Continue to dashboard'),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _finishOnboarding(ref),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCardConfigure(
    BuildContext context,
    WidgetRef ref,
    int cardId,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreditCardConfigureScreen(cardId: cardId),
      ),
    );
    ref.invalidate(setupCreditCardsProvider);
  }

  Future<void> _finishOnboarding(WidgetRef ref) async {
    await ref.read(onboardingRepositoryProvider).markOnboardingComplete();
    ref.invalidate(onboardingCompleteProvider);
  }
}

class _DetectedEmptyCard extends StatelessWidget {
  const _DetectedEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _DetectedCreditCardTile extends StatelessWidget {
  const _DetectedCreditCardTile({
    required this.card,
    required this.onConfigure,
  });

  final CreditCard card;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final configured = card.billDayOfMonth != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(card.colorValue).withValues(alpha: 0.15),
          child: Icon(
            Icons.credit_card,
            color: Color(card.colorValue),
            size: 20,
          ),
        ),
        title: Text(card.nickname),
        subtitle: Text('${card.bank} ••${card.lastFourDigits}'),
        trailing: configured
            ? const Icon(Icons.check_circle, color: Colors.green)
            : FilledButton.tonal(
                onPressed: onConfigure,
                child: const Text('Configure'),
              ),
        onTap: configured ? null : onConfigure,
      ),
    );
  }
}

class _DetectedBankAccountTile extends StatelessWidget {
  const _DetectedBankAccountTile({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.account_balance_outlined, size: 20),
        ),
        title: Text(account.nickname),
        subtitle: Text('${account.bank} ••${account.lastFourDigits}'),
        trailing: Text(
          'Detected',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
