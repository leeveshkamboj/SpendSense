import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/sms_capture/sms_sync_service.dart';
import 'package:spendsense/features/sms_capture/sms_sync_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

class SmsSyncListener extends ConsumerStatefulWidget {
  const SmsSyncListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SmsSyncListener> createState() => _SmsSyncListenerState();
}

class _SmsSyncListenerState extends ConsumerState<SmsSyncListener>
    with WidgetsBindingObserver {
  var _syncInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
    }
  }

  Future<void> _sync() async {
    if (_syncInFlight) {
      return;
    }

    _syncInFlight = true;
    try {
      final result = await ref.read(smsSyncServiceProvider).syncNewMessages();
      if (!mounted) {
        return;
      }

      if (result case ProcessedSmsSyncResult(:final capturedCount)
          when capturedCount > 0) {
        ref.invalidate(cardTransactionsProvider);
        ref.invalidate(bankAccountTransactionsProvider);
        ref.invalidate(cardTransactionPageProvider);
        ref.invalidate(filteredGroupedCardTransactionsProvider);
        ref.invalidate(filteredGroupedCardTransactionsWhenSearchingProvider);
        invalidateDashboardAndWidgets(ref);
      }
    } finally {
      _syncInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
