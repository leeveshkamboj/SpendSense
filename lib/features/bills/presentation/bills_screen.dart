import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(unpaidBillsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: bills.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No unpaid bills'));
          }

          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final bill = rows[index];
              return ListTile(
                title: Text(bill.cardNickname),
                subtitle: Text(
                  bill.dueDate == null
                      ? 'Due date not set'
                      : 'Due ${_formatDate(bill.dueDate!)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatPaise(bill.totalOutstandingPaise)),
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
