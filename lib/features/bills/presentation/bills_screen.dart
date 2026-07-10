import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/bills/presentation/record_bill_payment_sheet.dart';
import 'package:spendsense/features/shell/spend_sense_app_bar_actions.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(unpaidBillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBrandTitle(title: 'Bills'),
        actions: spendSenseAppBarActions(context),
      ),
      body: bills.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No unpaid bills'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final bill = rows[index];
              return ListTile(
                onTap: () => showRecordBillPaymentSheet(
                  context: context,
                  ref: ref,
                  bill: bill,
                ),
                title: Text(bill.cardNickname),
                subtitle: Text(_billSubtitle(bill)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatPaise(bill.totalOutstandingPaise),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (bill.netOutstandingPaise != bill.totalOutstandingPaise)
                      Text(
                        'Net ${formatPaise(bill.netOutstandingPaise)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                leading: _StatusIcon(status: bill.status),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _billSubtitle(BillSummary bill) {
    final dueLabel = bill.dueDate == null
        ? 'Due date not set'
        : 'Due ${_formatDate(bill.dueDate!)}';
    final paidLabel = bill.paymentsAppliedPaise > 0
        ? ' · Paid ${formatPaise(bill.paymentsAppliedPaise)}'
        : '';
    return '$dueLabel$paidLabel · Tap to record payment';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final BillingCycleStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (status) {
      BillingCycleStatus.overdue => (
          Icons.warning_amber_rounded,
          colorScheme.error,
        ),
      BillingCycleStatus.partiallyPaid => (
          Icons.payments_outlined,
          colorScheme.tertiary,
        ),
      _ => (Icons.request_page_outlined, colorScheme.primary),
    };

    return Icon(icon, color: color);
  }
}
