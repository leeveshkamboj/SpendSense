import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepository(ref.watch(databaseProvider));
});

final merchantDisplayNamesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final merchants = await ref.watch(merchantRepositoryProvider).listAll();
  return {
    for (final merchant in merchants)
      if (merchant.displayName?.trim().isNotEmpty ?? false)
        merchant.rawName: merchant.displayName!.trim(),
  };
});

final merchantForRawNameProvider =
    FutureProvider.family<MerchantRecord?, String>((ref, rawName) {
  return ref.watch(merchantRepositoryProvider).getByRawName(rawName);
});
