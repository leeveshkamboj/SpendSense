import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/settings/data/app_data_repository.dart';

final appDataRepositoryProvider = Provider<AppDataRepository>((ref) {
  return AppDataRepository(ref.watch(databaseProvider));
});
