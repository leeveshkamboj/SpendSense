import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/formatting/merchant_display.dart';
import 'package:spendsense/core/formatting/transaction_amount_display.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/location/domain/transaction_location.dart';
import 'package:spendsense/features/location/presentation/transaction_location_field.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/merchants/presentation/merchant_list_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/receipt_providers.dart';
import 'package:spendsense/features/transactions/data/receipt_repository.dart';
import 'package:spendsense/features/transactions/presentation/transaction_list_providers.dart';

final cardTransactionProvider =
    FutureProvider.family<CardTransaction?, int>((ref, id) {
  return ref.watch(cardTransactionRepositoryProvider).getById(id);
});

final cardTransactionTagsProvider =
    FutureProvider.family<List<String>, int>((ref, id) {
  return ref.watch(tagRepositoryProvider).listForCardTransaction(id);
});

final cardTransactionReceiptsProvider =
    FutureProvider.family<List<TransactionReceipt>, int>((ref, id) async {
  final service = await ref.watch(receiptServiceProvider.future);
  return service.listForTransaction(id);
});

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final int transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  final _personController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isRecoverable = false;
  bool _isRecurring = false;
  bool _isAddingReceipt = false;
  bool _isSaving = false;
  int? _loadedId;
  String? _loadedMerchantRawName;
  String? _loadedLocationRaw;
  TransactionLocation? _location;

  @override
  void dispose() {
    _personController.dispose();
    _displayNameController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _loadFields(CardTransaction tx) {
    if (_loadedId == tx.id) return;
    _loadedId = tx.id;
    _personController.text = tx.recoverablePerson ?? '';
    _notesController.text = tx.notes ?? '';
    _referenceController.text = tx.referenceNumber ?? '';
    _isRecoverable = tx.isRecoverable;
    _isRecurring = tx.isRecurring;
    _loadLocation(tx.location);
  }

  void _loadLocation(String? rawLocation) {
    if (_loadedLocationRaw == rawLocation) {
      return;
    }
    _loadedLocationRaw = rawLocation;
    _location = TransactionLocation.parse(rawLocation);
  }

  void _loadMerchantDisplayName(String rawName, String? displayName) {
    if (_loadedMerchantRawName == rawName) {
      return;
    }
    _loadedMerchantRawName = rawName;
    _displayNameController.text = displayName ?? '';
  }

  Future<void> _saveAll(CardTransaction tx) async {
    if (_isRecoverable && _personController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a person for recoverable expenses')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(recoverableRepositoryProvider).markRecoverable(
            transactionId: tx.id,
            isRecoverable: _isRecoverable,
            person: _isRecoverable ? _personController.text : null,
          );

      final repository = ref.read(merchantRepositoryProvider);
      await repository.ensureFromTransaction(rawName: tx.merchant);
      await repository.updateDefaults(
        rawName: tx.merchant,
        displayName: _displayNameController.text.trim(),
      );

      await ref.read(cardTransactionRepositoryProvider).updateDetails(
            transactionId: tx.id,
            amountPaise: tx.amountPaise,
            merchant: tx.merchant,
            category: tx.category,
            transactionAt: tx.transactionAt,
            billingCycleId: tx.billingCycleId,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            location: _location?.serialize(),
            referenceNumber: _referenceController.text.trim().isEmpty
                ? null
                : _referenceController.text.trim(),
            isRecurring: _isRecurring,
          );
      _invalidateAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickReceipt() async {
    setState(() => _isAddingReceipt = true);
    try {
      final service = await ref.read(receiptServiceProvider.future);
      final added = await service.pickAndAttachReceipt(widget.transactionId);
      if (!added) {
        return;
      }
      ref.invalidate(cardTransactionReceiptsProvider(widget.transactionId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt added')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add receipt: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingReceipt = false);
      }
    }
  }

  Future<void> _removeReceipt(TransactionReceipt receipt) async {
    try {
      final service = await ref.read(receiptServiceProvider.future);
      await service.removeReceipt(receipt);
      ref.invalidate(cardTransactionReceiptsProvider(widget.transactionId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt removed')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove receipt: $error')),
        );
      }
    }
  }

  Future<void> _openReceipt(TransactionReceipt receipt) async {
    final file = File(receipt.filePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt file not found')),
        );
      }
      return;
    }

    await Share.shareXFiles(
      [XFile(receipt.filePath)],
      text: p.basename(receipt.filePath),
    );
  }

  bool _isImageReceipt(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    return extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png' ||
        extension == '.webp' ||
        extension == '.heic';
  }

  String _receiptDisplayName(String filePath) {
    final baseName = p.basename(filePath);
    final underscoreIndex = baseName.indexOf('_');
    if (underscoreIndex == -1 || underscoreIndex == baseName.length - 1) {
      return baseName;
    }
    return baseName.substring(underscoreIndex + 1);
  }

  void _invalidateAll() {
    ref.invalidate(cardTransactionProvider(widget.transactionId));
    ref.invalidate(merchantForRawNameProvider);
    ref.invalidate(merchantDisplayNamesProvider);
    ref.invalidate(merchantsListProvider);
    ref.invalidate(cardTransactionsProvider);
    ref.invalidate(cardTransactionPageProvider);
    ref.invalidate(filteredGroupedCardTransactionsProvider);
    ref.invalidate(monthlyBudgetProgressProvider);
    ref.invalidate(unpaidBillsProvider);
    ref.invalidate(recoverableSummaryProvider);
    invalidateDashboardAndWidgets(ref);
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(cardTransactionProvider(widget.transactionId));
    final merchant = ref.watch(
      merchantForRawNameProvider(transaction.valueOrNull?.merchant ?? ''),
    );
    final tags = ref.watch(cardTransactionTagsProvider(widget.transactionId));
    final receipts =
        ref.watch(cardTransactionReceiptsProvider(widget.transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        actions: [
          TextButton(
            onPressed: transaction.valueOrNull == null || _isSaving
                ? null
                : () => _saveAll(transaction.valueOrNull!),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/transactions/${widget.transactionId}/edit'),
          ),
        ],
      ),
      body: transaction.when(
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          _loadFields(tx);
          _loadMerchantDisplayName(
            tx.merchant,
            merchant.valueOrNull?.displayName,
          );

          final scheme = Theme.of(context).colorScheme;
          final direction = cardTransactionDirection(tx.kind);
          final amountColor = transactionDirectionColor(scheme, direction);
          final merchantLabel = resolveMerchantDisplayLabel(
            tx.merchant,
            customDisplayName: _displayNameController.text.trim().isEmpty
                ? merchant.valueOrNull?.displayName
                : _displayNameController.text,
          );
          final parsedMerchantLabel = formatMerchantLabel(tx.merchant);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                merchantLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (merchantLabel != parsedMerchantLabel)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Parsed as $parsedMerchantLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display name',
                  helperText: 'Shown instead of ${tx.merchant}',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                formatSignedPaise(tx.amountPaise, direction),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
              ),
              Text(
                transactionDirectionLabel(direction),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text('Kind: ${tx.kind}'),
              Text('Source: ${tx.source}'),
              Text('Category: ${tx.category ?? 'Miscellaneous'}'),
              tags.when(
                data: (tagNames) => tagNames.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Tags: ${tagNames.join(', ')}'),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference number',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TransactionLocationField(
                location: _location,
                onChanged: (value) => setState(() => _location = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Recoverable',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as recoverable'),
                subtitle: const Text('Excluded from budgets'),
                value: _isRecoverable,
                onChanged: (value) => setState(() => _isRecoverable = value),
              ),
              if (_isRecoverable)
                TextField(
                  controller: _personController,
                  decoration: const InputDecoration(labelText: 'Person'),
                ),
              const SizedBox(height: 16),
              Text(
                'Recurring',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as recurring'),
                subtitle: const Text('Label and filter only'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Receipts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              receipts.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'No receipts attached',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    );
                  }

                  return Column(
                    children: [
                      for (final receipt in items)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openReceipt(receipt),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  if (_isImageReceipt(receipt.filePath))
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(receipt.filePath),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _ReceiptIcon(
                                          filePath: receipt.filePath,
                                        ),
                                      ),
                                    )
                                  else
                                    _ReceiptIcon(filePath: receipt.filePath),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _receiptDisplayName(receipt.filePath),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove receipt',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _removeReceipt(receipt),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => Text('Error loading receipts: $error'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isAddingReceipt ? null : _pickReceipt,
                icon: _isAddingReceipt
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file),
                label: Text(_isAddingReceipt ? 'Adding…' : 'Add receipt'),
              ),
              const SizedBox(height: 16),
              Text(
                'Original SMS',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(tx.rawSms ?? 'Not available'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ReceiptIcon extends StatelessWidget {
  const _ReceiptIcon({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    final isPdf = p.extension(filePath).toLowerCase() == '.pdf';
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
