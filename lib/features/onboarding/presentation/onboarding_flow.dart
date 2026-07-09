import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/presentation/setup_wizard_screen.dart';
import 'package:spendsense/features/onboarding/presentation/sms_import_screen.dart';
import 'package:spendsense/features/onboarding/presentation/welcome_screen.dart';

enum OnboardingStep { welcome, import, wizard }

final onboardingStepProvider = StateProvider<OnboardingStep>(
  (ref) => OnboardingStep.welcome,
);

class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingStepProvider);

    return switch (step) {
      OnboardingStep.welcome => WelcomeScreen(
          onFreshStart: () =>
              ref.read(onboardingStepProvider.notifier).state =
                  OnboardingStep.import,
          onRestore: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Restore from backup will be available soon.'),
              ),
            );
          },
        ),
      OnboardingStep.import => SmsImportScreen(
          onComplete: () =>
              ref.read(onboardingStepProvider.notifier).state =
                  OnboardingStep.wizard,
        ),
      OnboardingStep.wizard => SetupWizardScreen(),
    };
  }
}
