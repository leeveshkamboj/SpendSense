import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_restore_screen.dart';
import 'package:spendsense/features/onboarding/presentation/permissions_setup_screen.dart';
import 'package:spendsense/features/onboarding/presentation/setup_wizard_screen.dart';
import 'package:spendsense/features/onboarding/presentation/sms_import_screen.dart';
import 'package:spendsense/features/onboarding/presentation/welcome_screen.dart';

enum OnboardingStep { welcome, restore, permissions, import, wizard }

final onboardingStepProvider = StateProvider<OnboardingStep>(
  (ref) => OnboardingStep.welcome,
);

final onboardingRestoreDateProvider = StateProvider<DateTime?>(
  (ref) => null,
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
                  OnboardingStep.permissions,
          onRestore: () =>
              ref.read(onboardingStepProvider.notifier).state =
                  OnboardingStep.restore,
        ),
      OnboardingStep.restore => OnboardingRestoreScreen(
          onComplete: (summary) {
            ref.read(onboardingRestoreDateProvider.notifier).state =
                summary.backupDate;
            ref.read(onboardingStepProvider.notifier).state =
                OnboardingStep.permissions;
          },
        ),
      OnboardingStep.permissions => PermissionsSetupScreen(
          onComplete: () =>
              ref.read(onboardingStepProvider.notifier).state =
                  OnboardingStep.import,
        ),
      OnboardingStep.import => SmsImportScreen(
          since: ref.watch(onboardingRestoreDateProvider),
          onComplete: () =>
              ref.read(onboardingStepProvider.notifier).state =
                  OnboardingStep.wizard,
        ),
      OnboardingStep.wizard => SetupWizardScreen(),
    };
  }
}
