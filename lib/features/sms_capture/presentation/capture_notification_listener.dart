import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
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
            onPressed: () => _reviewCapture(context, ref, next),
          ),
        ),
      );

      if (!next.isBankAccount) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Mark ${next.merchant} as recoverable?'),
            action: SnackBarAction(
              label: 'Recoverable',
              onPressed: () async {
                final person = await _promptForPerson(context, ref);
                if (person == null || person.trim().isEmpty) {
                  return;
                }

                await ref.read(recoverableRepositoryProvider).markRecoverable(
                      transactionId: next.transactionId,
                      isRecoverable: true,
                      person: person.trim(),
                    );
                ref.invalidate(cardTransactionsProvider);
                ref.invalidate(recoverableSummaryProvider);
                ref.read(captureNotificationProvider.notifier).state = null;
              },
            ),
          ),
        );
      }
    });

    return child;
  }

  Future<void> _reviewCapture(
    BuildContext context,
    WidgetRef ref,
    CaptureNotificationEvent next,
  ) async {
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
  }

  Future<String?> _promptForPerson(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final names = await ref.read(recoverableRepositoryProvider).listPersonNames();

    if (!context.mounted) {
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Who owes this?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Person'),
            ),
            if (names.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final name in names.take(3))
                    ActionChip(
                      label: Text(name),
                      onPressed: () => Navigator.of(context).pop(name),
                    ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
