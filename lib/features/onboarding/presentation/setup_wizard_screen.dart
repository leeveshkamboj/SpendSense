import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_setup_screen.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Configure at least one credit card to reach the dashboard. '
            'Bank accounts and budgets are optional.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreditCardSetupScreen(),
                ),
              );
            },
            child: const Text('Set up credit card'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              await ref
                  .read(onboardingRepositoryProvider)
                  .markOnboardingComplete();
              ref.invalidate(onboardingCompleteProvider);
            },
            child: const Text('Skip to dashboard'),
          ),
          const SizedBox(height: 24),
          const AccountsScreen(),
        ],
      ),
    );
  }
}
