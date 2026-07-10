import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/analytics/data/analytics_providers.dart';
import 'package:spendsense/features/bills/data/bills_providers.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/categories/data/category_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/reports/data/live_report_export_service.dart';
import 'package:spendsense/features/reports/data/platform_report_share_gateway.dart';
import 'package:spendsense/features/reports/data/report_repository.dart';
import 'package:spendsense/features/reports/data/report_share_gateway.dart';
import 'package:spendsense/features/reports/domain/report_export_service.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final reportShareGatewayProvider = Provider<ReportShareGateway>(
  (ref) => PlatformReportShareGateway(),
);

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
    creditCards: ref.watch(creditCardRepositoryProvider),
    bankAccounts: ref.watch(bankAccountRepositoryProvider),
    categories: ref.watch(categoryRepositoryProvider),
    budgets: ref.watch(budgetRepositoryProvider),
    bills: ref.watch(billsRepositoryProvider),
    analytics: ref.watch(analyticsRepositoryProvider),
    recoverables: ref.watch(recoverableRepositoryProvider),
  );
});

final reportExportServiceProvider = Provider<ReportExportService>((ref) {
  return LiveReportExportService(
    shareGateway: ref.watch(reportShareGatewayProvider),
  );
});
