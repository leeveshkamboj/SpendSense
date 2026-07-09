import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/merchants/domain/merchant_list_item.dart';

final merchantsListProvider =
    FutureProvider<List<MerchantListItem>>((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  final merchants = await repository.listAll();

  return [
    for (final merchant in merchants)
      MerchantListItem(
        rawName: merchant.rawName,
        displayName: merchant.displayName,
        defaultCategory: await repository.resolveDefaultCategory(
          merchant.rawName,
        ),
        tags: await repository.resolveDefaultTags(merchant.rawName),
      ),
  ];
});
