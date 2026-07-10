import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/presentation/sms_import_screen.dart';
import 'package:spendsense/features/onboarding/sms_import_log.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class SmsReimportScreen extends ConsumerStatefulWidget {
  const SmsReimportScreen({super.key});

  @override
  ConsumerState<SmsReimportScreen> createState() => _SmsReimportScreenState();
}

class _SmsReimportScreenState extends ConsumerState<SmsReimportScreen> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    await ref.read(onboardingRepositoryProvider).resetSmsImport();
    smsImportLog('SMS re-import requested from settings');
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SmsImportScreen(
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
    );
  }
}
