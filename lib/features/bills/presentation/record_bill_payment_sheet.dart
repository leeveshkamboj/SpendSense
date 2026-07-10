import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/dashboard/data/dashboard_providers.dart';

Future<void> showRecordBillPaymentSheet({
  required BuildContext context,
  required WidgetRef ref,
  required BillSummary bill,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _RecordBillPaymentSheet(
      bill: bill,
      onSaved: () async {
        ref.invalidate(unpaidBillsProvider);
        ref.invalidate(dashboardCardSpendProvider);
      },
    ),
  );
}

class _RecordBillPaymentSheet extends ConsumerStatefulWidget {
  const _RecordBillPaymentSheet({
    required this.bill,
    required this.onSaved,
  });

  final BillSummary bill;
  final Future<void> Function() onSaved;

  @override
  ConsumerState<_RecordBillPaymentSheet> createState() =>
      _RecordBillPaymentSheetState();
}

class _RecordBillPaymentSheetState extends ConsumerState<_RecordBillPaymentSheet> {
  final _amountController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _markPaidInFull() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(billsRepositoryProvider)
          .markBillPaidInFull(cycleId: widget.bill.cycleId);
      await widget.onSaved();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill marked as paid')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update bill: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _recordPartialPayment() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid payment amount')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(billsRepositoryProvider).recordManualPayment(
            cycleId: widget.bill.cycleId,
            paymentPaise: (amount * 100).round(),
          );
      await widget.onSaved();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not record payment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            bill.cardNickname,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            bill.dueDate == null
                ? 'Due date not set'
                : 'Due ${_formatDate(bill.dueDate!)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          _AmountRow(label: 'Bill amount', amountPaise: bill.billAmountPaise),
          _AmountRow(
            label: 'Paid so far',
            amountPaise: bill.paymentsAppliedPaise,
          ),
          _AmountRow(
            label: 'Remaining',
            amountPaise: bill.totalOutstandingPaise,
            emphasized: true,
          ),
          if (bill.netOutstandingPaise != bill.totalOutstandingPaise) ...[
            const SizedBox(height: 4),
            Text(
              'Net after recoverables: ${formatPaise(bill.netOutstandingPaise)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _markPaidInFull,
            child: const Text('Mark as fully paid'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Partial payment amount',
              prefixText: '₹ ',
              hintText: 'Enter amount paid',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _saving ? null : _recordPartialPayment,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Record partial payment'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amountPaise,
    this.emphasized = false,
  });

  final String label;
  final int amountPaise;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            formatPaise(amountPaise),
            style: emphasized
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
