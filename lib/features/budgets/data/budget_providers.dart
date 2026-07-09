import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(
    database: ref.watch(databaseProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
  );
});

final monthlyBudgetProgressProvider = FutureProvider<BudgetProgressSnapshot?>((ref) {
  return ref.watch(budgetRepositoryProvider).monthlyProgress(asOf: DateTime.now());
});

final categoryBudgetsProvider = FutureProvider<List<CategoryBudget>>((ref) {
  return ref.watch(budgetRepositoryProvider).listCategoryBudgets();
});
