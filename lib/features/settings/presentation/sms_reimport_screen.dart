import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/presentation/sms_import_screen.dart';
import 'package:spendsense/features/onboarding/presentation/sms_import_setup_screen.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class SmsReimportScreen extends ConsumerStatefulWidget {
  const SmsReimportScreen({super.key});

  @override
  ConsumerState<SmsReimportScreen> createState() => _SmsReimportScreenState();
}

class _SmsReimportScreenState extends ConsumerState<SmsReimportScreen> {
  var _step = _ReimportStep.chooseWindow;

  Future<void> _startImport() async {
    await ref.read(onboardingRepositoryProvider).resetSmsImport();
    if (mounted) {
      setState(() => _step = _ReimportStep.importing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _ReimportStep.chooseWindow => SmsImportSetupScreen(
          onContinue: _startImport,
          onSkip: () {
            if (context.mounted) {
              context.pop();
            }
          },
        ),
      _ReimportStep.importing => SmsImportScreen(
          onComplete: () {
            ref.invalidate(cardTransactionsProvider);
            ref.invalidate(cardTransactionPageProvider);
            ref.invalidate(filteredGroupedCardTransactionsProvider);
            ref.invalidate(filteredGroupedCardTransactionsWhenSearchingProvider);
            invalidateDashboardAndWidgets(ref);
            if (context.mounted) {
              context.pop();
            }
          },
        ),
    };
  }
}

enum _ReimportStep { chooseWindow, importing }
