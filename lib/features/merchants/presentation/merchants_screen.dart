import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/categories/data/category_providers.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/merchants/domain/merchant_list_item.dart';
import 'package:spendsense/features/merchants/presentation/merchant_list_providers.dart';

class MerchantsScreen extends ConsumerWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchants = ref.watch(merchantsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Merchants')),
      body: merchants.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No merchants yet'));
          }

          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final merchant = rows[index];
              return ListTile(
                title: Text(merchant.title),
                subtitle: Text(_subtitleFor(merchant)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showEditDialog(context, ref, merchant),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _subtitleFor(MerchantListItem merchant) {
    final tags = merchant.tags.isEmpty
        ? 'No tags'
        : merchant.tags.join(', ');
    return '${merchant.defaultCategory} · $tags';
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MerchantListItem merchant,
  ) async {
    final categories = await ref.read(categoryNamesProvider.future);
    final displayNameController = TextEditingController(
      text: merchant.displayName ?? '',
    );
    final tagsController = TextEditingController(
      text: merchant.tags.join(', '),
    );
    var selectedCategory = merchant.defaultCategory;

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${merchant.rawName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Default category',
                      ),
                      items: [
                        for (final category in categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Default tags (comma-separated)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final repository = ref.read(merchantRepositoryProvider);
                    await repository.updateDefaults(
                      rawName: merchant.rawName,
                      displayName: displayNameController.text,
                      defaultCategory: selectedCategory,
                      tagNames: tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty)
                          .toList(),
                    );
                    ref.invalidate(merchantsListProvider);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    displayNameController.dispose();
    tagsController.dispose();
  }
}
