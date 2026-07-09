import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/data/bank_account_repository.dart';

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountRepository(ref.watch(databaseProvider));
});
