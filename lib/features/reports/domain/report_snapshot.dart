import 'package:spendsense/features/analytics/domain/analytics_snapshot.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';

class ReportBillingCycleRow {
  const ReportBillingCycleRow({
    required this.id,
    required this.creditCardId,
    required this.cardNickname,
    required this.startDate,
    required this.endDate,
    required this.billGenerated,
    required this.dueDate,
    required this.paymentsAppliedPaise,
  });

  final int id;
  final int creditCardId;
  final String cardNickname;
  final DateTime startDate;
  final DateTime endDate;
  final bool billGenerated;
  final DateTime? dueDate;
  final int paymentsAppliedPaise;
}

class ReportAccountRow {
  const ReportAccountRow({
    required this.id,
    required this.kind,
    required this.bank,
    required this.nickname,
    required this.lastFourDigits,
    required this.isArchived,
  });

  final int id;
  final String kind;
  final String bank;
  final String nickname;
  final String lastFourDigits;
  final bool isArchived;
}

class ReportMonthlyBudgetRow {
  const ReportMonthlyBudgetRow({
    required this.limitPaise,
    required this.spentPaise,
    required this.remainingPaise,
    required this.periodStart,
    required this.periodEnd,
  });

  final int limitPaise;
  final int spentPaise;
  final int remainingPaise;
  final DateTime periodStart;
  final DateTime periodEnd;
}

class ReportCategoryBudgetRow {
  const ReportCategoryBudgetRow({
    required this.category,
    required this.limitPaise,
  });

  final String category;
  final int limitPaise;
}

class ReportBillRow {
  const ReportBillRow({
    required this.cycleId,
    required this.cardNickname,
    required this.dueDate,
    required this.totalOutstandingPaise,
    required this.netOutstandingPaise,
    required this.status,
  });

  final int cycleId;
  final String cardNickname;
  final DateTime? dueDate;
  final int totalOutstandingPaise;
  final int netOutstandingPaise;
  final String status;
}

class ReportSnapshot {
  const ReportSnapshot({
    required this.exportedAt,
    required this.cardTransactions,
    required this.billingCycles,
    required this.categories,
    required this.accounts,
    required this.monthlyBudget,
    required this.categoryBudgets,
    required this.bills,
    required this.analytics,
    required this.recoverablesByPerson,
  });

  final DateTime exportedAt;
  final List<ReportCardTransactionRow> cardTransactions;
  final List<ReportBillingCycleRow> billingCycles;
  final List<String> categories;
  final List<ReportAccountRow> accounts;
  final ReportMonthlyBudgetRow? monthlyBudget;
  final List<ReportCategoryBudgetRow> categoryBudgets;
  final List<ReportBillRow> bills;
  final AnalyticsSnapshot? analytics;
  final Map<String, int> recoverablesByPerson;
}
