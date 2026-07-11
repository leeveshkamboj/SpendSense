import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';
import 'package:spendsense/features/sms_capture/sms_debug_log.dart';
import 'package:spendsense/features/sms_capture/sms_sync_service.dart';
import 'package:spendsense/features/sms_capture/sms_sync_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

const _smsSyncNudgeChannelName = 'com.spendsense.spendsense/sms_sync_nudge';

class SmsSyncListener extends ConsumerStatefulWidget {
  const SmsSyncListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SmsSyncListener> createState() => _SmsSyncListenerState();
}

class _SmsSyncListenerState extends ConsumerState<SmsSyncListener>
    with WidgetsBindingObserver {
  static const _nudgeChannel = MethodChannel(_smsSyncNudgeChannelName);

  var _syncInFlight = false;
  var _syncQueued = false;
  Timer? _periodicSync;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nudgeChannel.setMethodCallHandler(_onNativeNudge);
    smsDebugLog('SmsSyncListener mounted');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sync(reason: 'postFrame');
      _startPeriodicSync();
    });
  }

  @override
  void dispose() {
    _periodicSync?.cancel();
    _nudgeChannel.setMethodCallHandler(null);
    WidgetsBinding.instance.removeObserver(this);
    smsDebugLog('SmsSyncListener disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    smsDebugLog('lifecycle=$state');
    switch (state) {
      case AppLifecycleState.resumed:
        _startPeriodicSync();
        // Background capture may have written while we were paused; providers
        // still hold stale data even when sync only sees duplicates.
        _sync(forceRefresh: true, reason: 'resumed');
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _periodicSync?.cancel();
        _periodicSync = null;
    }
  }

  Future<void> _onNativeNudge(MethodCall call) async {
    smsDebugLog('native nudge method=${call.method}');
    switch (call.method) {
      case 'processSms':
        final args = Map<Object?, Object?>.from(call.arguments as Map);
        final body = args['body'] as String? ?? '';
        final receivedAtMs = (args['receivedAtMs'] as num?)?.toInt();
        if (body.isEmpty) {
          await _sync(forceRefresh: true, reason: 'processSms-empty');
          return;
        }
        await _processLiveSms(body, receivedAtMs);
      case 'syncNow':
        // MMS/RCS parts can land slightly after the nudge.
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) {
          return;
        }
        await _sync(forceRefresh: true, reason: 'nudge');
      default:
        break;
    }
  }

  Future<void> _processLiveSms(String body, int? receivedAtMs) async {
    smsDebugLog('live processSms bodyLen=${body.length}');
    try {
      final result =
          await ref.read(smsCaptureServiceProvider).processSms(body);
      smsDebugLog('live processSms result=${result.name}');

      if (!mounted) {
        return;
      }

      if (result == SmsCaptureResult.captured ||
          result == SmsCaptureResult.duplicate) {
        if (receivedAtMs != null) {
          final settings = ref.read(onboardingRepositoryProvider);
          final receivedAt = DateTime.fromMillisecondsSinceEpoch(receivedAtMs);
          final lastSync = await settings.lastSmsSyncAt();
          if (lastSync == null || receivedAt.isAfter(lastSync)) {
            await settings.saveLastSmsSyncAt(receivedAt);
          }
        }
      }

      if (result == SmsCaptureResult.captured) {
        _invalidateLists();
      }

      // Also catch any sibling MMS/RCS that landed with this SMS.
      await _sync(
        forceRefresh: true,
        reason: 'afterLive',
      );
    } catch (error, stackTrace) {
      smsDebugLog('live processSms failed', error, stackTrace);
      await _sync(forceRefresh: true, reason: 'liveFailed');
    }
  }

  void _startPeriodicSync() {
    _periodicSync?.cancel();
    // RCS never fires SMS_RECEIVED — poll the MMS/SMS providers while open.
    _periodicSync = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _sync(reason: 'periodic'),
    );
  }

  Future<void> _sync({
    bool forceRefresh = false,
    String reason = 'unknown',
  }) async {
    if (_syncInFlight) {
      _syncQueued = true;
      smsDebugLog('sync queued reason=$reason');
      return;
    }

    _syncInFlight = true;
    try {
      do {
        _syncQueued = false;
        smsDebugLog('sync running reason=$reason');
        final result = await ref.read(smsSyncServiceProvider).syncNewMessages();
        if (!mounted) {
          return;
        }

        final summary = switch (result) {
          SkippedSmsSyncResult(:final reason) => 'skipped:${reason.name}',
          ProcessedSmsSyncResult(
            :final messageCount,
            :final capturedCount,
            :final duplicateCount,
            :final ignoredCount,
          ) =>
            'processed msgs=$messageCount captured=$capturedCount '
                'dup=$duplicateCount ignored=$ignoredCount',
        };
        smsDebugLog('sync result reason=$reason $summary');

        final captured = switch (result) {
          ProcessedSmsSyncResult(:final capturedCount) => capturedCount,
          _ => 0,
        };

        if (forceRefresh || captured > 0) {
          _invalidateLists();
          smsDebugLog('providers invalidated captured=$captured');
        }
      } while (_syncQueued && mounted);
    } catch (error, stackTrace) {
      smsDebugLog('sync failed reason=$reason', error, stackTrace);
    } finally {
      _syncInFlight = false;
    }
  }

  void _invalidateLists() {
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(bankAccountTransactionsProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(filteredGroupedCardTransactionsWhenSearchingProvider);
    // Refresh the paging notifier in place — invalidate alone can leave the
    // transactions tab on an empty/loading flash without new rows.
    ref.read(cardTransactionPageProvider.notifier).refresh();
    invalidateDashboardAndWidgets(ref);
    smsDebugLog('lists refreshed');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
