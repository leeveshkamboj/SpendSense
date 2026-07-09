import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/sms_capture/capture_notification_provider.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

class CaptureNotificationListener extends ConsumerWidget {
  const CaptureNotificationListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CaptureNotificationEvent?>(captureNotificationProvider, (
      previous,
      next,
    ) {
      if (next == null) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Captured ${formatPaise(next.amountPaise)} at ${next.merchant}',
          ),
          action: SnackBarAction(
            label: 'Review',
            onPressed: () async {
              if (next.isBankAccount) {
                await ref
                    .read(bankAccountTransactionRepositoryProvider)
                    .markReviewed(next.transactionId);
                ref.invalidate(bankAccountTransactionsProvider);
              } else {
                await ref
                    .read(cardTransactionRepositoryProvider)
                    .markReviewed(next.transactionId);
                ref.invalidate(cardTransactionsProvider);
              }
              ref.read(captureNotificationProvider.notifier).state = null;
              if (context.mounted) {
                context.push('/transactions/${next.transactionId}');
              }
            },
          ),
        ),
      );
    });

    return child;
  }
}
