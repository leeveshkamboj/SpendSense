import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/categories/data/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final categoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  await repository.ensureDefaults();
  return repository.listNames();
});
