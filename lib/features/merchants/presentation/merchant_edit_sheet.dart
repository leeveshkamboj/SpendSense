import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/categories/data/category_providers.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/merchants/domain/merchant_list_item.dart';
import 'package:spendsense/features/merchants/presentation/merchant_list_providers.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';

/// Result of editing a merchant's display name, default category, and tags.
class MerchantEditResult {
  const MerchantEditResult({
    required this.displayName,
    required this.defaultCategory,
    required this.tagNames,
  });

  final String displayName;
  final String defaultCategory;
  final List<String> tagNames;
}

/// Opens the merchant defaults form (display name, category, tags).
///
/// Returns the saved values, or null if cancelled.
Future<MerchantEditResult?> showMerchantEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required MerchantListItem merchant,
  int? applyTagsToCardTransactionId,
}) async {
  final categories = await ref.read(categoryNamesProvider.future);
  if (!context.mounted) {
    return null;
  }

  final result = await showModalBottomSheet<MerchantEditResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _MerchantEditSheet(
      merchant: merchant,
      categories: categories,
    ),
  );

  if (result == null) {
    return null;
  }

  final repository = ref.read(merchantRepositoryProvider);
  await repository.ensureFromTransaction(rawName: merchant.rawName);
  await repository.updateDefaults(
    rawName: merchant.rawName,
    displayName: result.displayName,
    defaultCategory: result.defaultCategory,
    tagNames: result.tagNames,
  );

  if (applyTagsToCardTransactionId != null) {
    await ref.read(tagRepositoryProvider).setForCardTransaction(
          transactionId: applyTagsToCardTransactionId,
          tagNames: result.tagNames,
        );
  }

  ref.invalidate(merchantsListProvider);
  ref.invalidate(merchantDisplayNamesProvider);
  ref.invalidate(merchantForRawNameProvider);

  return result;
}

class _MerchantEditSheet extends StatefulWidget {
  const _MerchantEditSheet({
    required this.merchant,
    required this.categories,
  });

  final MerchantListItem merchant;
  final List<String> categories;

  @override
  State<_MerchantEditSheet> createState() => _MerchantEditSheetState();
}

class _MerchantEditSheetState extends State<_MerchantEditSheet> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _tagsController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.merchant.displayName ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.merchant.tags.join(', '),
    );
    _selectedCategory = widget.merchant.defaultCategory;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final categoryValue = widget.categories.contains(_selectedCategory)
        ? _selectedCategory
        : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit merchant',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.merchant.rawName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _displayNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display name',
                helperText: 'Shown on transactions instead of the raw name',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: categoryValue,
              decoration: const InputDecoration(
                labelText: 'Default category',
              ),
              items: [
                for (final category in widget.categories)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Default tags',
                helperText: 'Comma-separated, e.g. Personal, Office',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  MerchantEditResult(
                    displayName: _displayNameController.text.trim(),
                    defaultCategory: _selectedCategory,
                    tagNames: _tagsController.text
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList(),
                  ),
                );
              },
              child: const Text('Save merchant'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
