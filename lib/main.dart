import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/app.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: const _AppBootstrap(),
    ),
  );
}

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseProvider);
    return const OnboardingGate(child: SpendSenseApp());
  }
}
