import 'package:spendsense/features/budgets/domain/budget_transaction.dart';

class AnalyticsTransaction {
  const AnalyticsTransaction({
    required this.source,
    required this.kind,
    required this.isRecoverable,
    required this.amountPaise,
    required this.merchant,
    this.category,
    this.cardId,
    this.cardNickname,
    this.transactionAt,
    this.tags = const [],
    this.billingCycleId,
  });

  final BudgetTransactionSource source;
  final BudgetTransactionKind kind;
  final bool isRecoverable;
  final int amountPaise;
  final String merchant;
  final String? category;
  final int? cardId;
  final String? cardNickname;
  final DateTime? transactionAt;
  final List<String> tags;
  final int? billingCycleId;
}
