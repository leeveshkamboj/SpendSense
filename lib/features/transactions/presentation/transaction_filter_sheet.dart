import 'package:flutter/material.dart';
import 'package:spendsense/features/transactions/domain/transaction_filters.dart';

Future<TransactionFilters?> showTransactionFilterSheet({
  required BuildContext context,
  required TransactionFilters initial,
  required List<String> categories,
}) {
  return showModalBottomSheet<TransactionFilters>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _TransactionFilterSheet(
      initial: initial,
      categories: categories,
    ),
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  const _TransactionFilterSheet({
    required this.initial,
    required this.categories,
  });

  final TransactionFilters initial;
  final List<String> categories;

  @override
  State<_TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  late TransactionFilters _filters;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  static const _kinds = ['expense', 'refund', 'cashback', 'adjustment', 'payment'];
  static const _sources = ['SMS', 'Manual'];

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
    if (_filters.minAmountPaise != null) {
      _minAmountController.text = (_filters.minAmountPaise! / 100).toString();
    }
    if (_filters.maxAmountPaise != null) {
      _maxAmountController.text = (_filters.maxAmountPaise! / 100).toString();
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  int? _parseAmountPaise(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final rupees = double.tryParse(trimmed);
    if (rupees == null) {
      return null;
    }
    return (rupees * 100).round();
  }

  Future<void> _pickDate({
    required bool isFrom,
  }) async {
    final initial = isFrom ? _filters.dateFrom : _filters.dateTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _filters = isFrom
          ? _filters.copyWith(dateFrom: picked)
          : _filters.copyWith(dateTo: picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Min amount (₹)',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {
                      _filters = _filters.copyWith(
                        minAmountPaise: _parseAmountPaise(_minAmountController.text),
                        clearMinAmount:
                            _minAmountController.text.trim().isEmpty,
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Max amount (₹)',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {
                      _filters = _filters.copyWith(
                        maxAmountPaise: _parseAmountPaise(_maxAmountController.text),
                        clearMaxAmount:
                            _maxAmountController.text.trim().isEmpty,
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isFrom: true),
                    child: Text(
                      _filters.dateFrom == null
                          ? 'From date'
                          : 'From ${_formatDate(_filters.dateFrom!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isFrom: false),
                    child: Text(
                      _filters.dateTo == null
                          ? 'To date'
                          : 'To ${_formatDate(_filters.dateTo!)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownMenu<String?>(
              label: const Text('Category'),
              initialSelection: _filters.category,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any category'),
                for (final category in widget.categories)
                  DropdownMenuEntry(value: category, label: category),
              ],
              onSelected: (value) => setState(
                () => _filters = _filters.copyWith(
                  category: value,
                  clearCategory: value == null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String?>(
              label: const Text('Type'),
              initialSelection: _filters.kind,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any type'),
                for (final kind in _kinds)
                  DropdownMenuEntry(value: kind, label: kind),
              ],
              onSelected: (value) => setState(
                () => _filters = _filters.copyWith(
                  kind: value,
                  clearKind: value == null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String?>(
              label: const Text('Source'),
              initialSelection: _filters.source,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any source'),
                for (final source in _sources)
                  DropdownMenuEntry(value: source, label: source),
              ],
              onSelected: (value) => setState(
                () => _filters = _filters.copyWith(
                  source: value,
                  clearSource: value == null,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recurring only'),
              value: _filters.recurringOnly,
              onChanged: (value) =>
                  setState(() => _filters = _filters.copyWith(recurringOnly: value)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reviewed only'),
              value: _filters.reviewed == true,
              onChanged: (value) => setState(
                () => _filters = _filters.copyWith(
                  reviewed: value ? true : null,
                  clearReviewed: !value,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Unreviewed only'),
              value: _filters.reviewed == false,
              onChanged: (value) => setState(
                () => _filters = _filters.copyWith(
                  reviewed: value ? false : null,
                  clearReviewed: !value,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Has notes'),
              value: _filters.hasNotes == true,
              onChanged: (value) => setState(
                () => _filters = _filters.copyWith(
                  hasNotes: value ? true : null,
                  clearHasNotes: !value,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Has receipt'),
              value: _filters.hasReceipt == true,
              onChanged: (value) => setState(
                () => _filters = _filters.copyWith(
                  hasReceipt: value ? true : null,
                  clearHasReceipt: !value,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(const TransactionFilters()),
                  child: const Text('Clear'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_filters),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
