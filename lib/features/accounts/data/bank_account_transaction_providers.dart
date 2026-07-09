import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/transactions/domain/grouped_bank_transactions.dart';

final bankAccountTransactionRepositoryProvider =
    Provider<BankAccountTransactionRepository>((ref) {
  return BankAccountTransactionRepository(ref.watch(databaseProvider));
});

final bankAccountTransactionsProvider =
    FutureProvider<List<BankAccountTransaction>>((ref) {
  return ref.watch(bankAccountTransactionRepositoryProvider).listAll();
});

final groupedBankTransactionsProvider =
    FutureProvider<List<BankTransactionMonthGroup>>((ref) async {
  final transactions = await ref.watch(bankAccountTransactionsProvider.future);
  return groupBankTransactionsByMonth(
    transactions: transactions,
    now: DateTime.now(),
  );
});
