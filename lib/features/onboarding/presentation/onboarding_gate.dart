import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_flow.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(databaseProvider));
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingRepositoryProvider).isOnboardingComplete();
});

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingCompleteProvider);

    return onboarding.when(
      data: (complete) => complete ? child : const OnboardingNavigator(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

class OnboardingNavigator extends StatelessWidget {
  const OnboardingNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const OnboardingFlow(),
        );
      },
    );
  }
}
