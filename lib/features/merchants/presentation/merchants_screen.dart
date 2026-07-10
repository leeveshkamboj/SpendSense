import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/merchants/domain/merchant_list_item.dart';
import 'package:spendsense/features/merchants/presentation/merchant_edit_sheet.dart';
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
                onTap: () => showMerchantEditSheet(
                  context: context,
                  ref: ref,
                  merchant: merchant,
                ),
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
}
