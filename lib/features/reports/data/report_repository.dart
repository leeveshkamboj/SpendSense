import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/analytics/data/analytics_repository.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/budgets/data/budget_repository.dart';
import 'package:spendsense/features/categories/data/category_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/reports/domain/report_card_transaction_row.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class ReportRepository {
  ReportRepository({
    required CardTransactionRepository cardTransactions,
    required BankAccountTransactionRepository bankTransactions,
    required CreditCardRepository creditCards,
    required BankAccountRepository bankAccounts,
    required CategoryRepository categories,
    required BudgetRepository budgets,
    required BillsRepository bills,
    required AnalyticsRepository analytics,
    required RecoverableRepository recoverables,
  })  : _cardTransactions = cardTransactions,
        _bankTransactions = bankTransactions,
        _creditCards = creditCards,
        _bankAccounts = bankAccounts,
        _categories = categories,
        _budgets = budgets,
        _bills = bills,
        _analytics = analytics,
        _recoverables = recoverables;

  final CardTransactionRepository _cardTransactions;
  final BankAccountTransactionRepository _bankTransactions;
  final CreditCardRepository _creditCards;
  final BankAccountRepository _bankAccounts;
  final CategoryRepository _categories;
  final BudgetRepository _budgets;
  final BillsRepository _bills;
  final AnalyticsRepository _analytics;
  final RecoverableRepository _recoverables;

  Future<ReportSnapshot> buildSnapshot({required DateTime asOf}) async {
    final exportedAt = asOf;
    final cards = await _creditCards.listActive();
    final cardNicknameById = {for (final card in cards) card.id: card.nickname};
    final bankAccountRows = await _bankAccounts.listActive();
    final bankNicknameById = {
      for (final account in bankAccountRows) account.id: account.nickname,
    };

    final cardTxRows = await _cardTransactions.listAll();
    final bankTxRows = await _bankTransactions.listAll();
    final categoryNames = await _categories.listNames();
    final monthlyProgress = await _budgets.monthlyProgress(asOf: asOf);
    final categoryBudgets = await _budgets.listCategoryBudgets();
    final unpaidBills = await _bills.listUnpaidBills(asOf: asOf);
    final recoverablesByPerson = await _recoverables.summaryByPerson();
    final analyticsSnapshot = await _analytics.snapshot(asOf: asOf);

    final billingCycles = <ReportBillingCycleRow>[];
    for (final card in cards) {
      final cycles = await _creditCards.listCycles(card.id);
      for (final cycle in cycles) {
        billingCycles.add(
          ReportBillingCycleRow(
            id: cycle.id,
            creditCardId: card.id,
            cardNickname: card.nickname,
            startDate: cycle.startDate,
            endDate: cycle.endDate,
            billGenerated: cycle.billGenerated,
            dueDate: cycle.dueDate,
            paymentsAppliedPaise: cycle.paymentsAppliedPaise,
          ),
        );
      }
    }

    return ReportSnapshot(
      exportedAt: exportedAt,
      cardTransactions: [
        for (final tx in cardTxRows)
          ReportCardTransactionRow(
            id: tx.id,
            creditCardId: tx.creditCardId,
            cardNickname: cardNicknameById[tx.creditCardId] ?? 'Unknown card',
            billingCycleId: tx.billingCycleId,
            kind: tx.kind,
            amountPaise: tx.amountPaise,
            merchant: tx.merchant,
            transactionAt: tx.transactionAt,
            source: tx.source,
            referenceNumber: tx.referenceNumber,
            category: tx.category,
            isRecoverable: tx.isRecoverable,
            recoverablePerson: tx.recoverablePerson,
            isReviewed: tx.isReviewed,
            notes: tx.notes,
            location: tx.location,
            createdAt: tx.createdAt,
          ),
      ],
      bankTransactions: [
        for (final tx in bankTxRows)
          ReportBankTransactionRow(
            id: tx.id,
            bankAccountId: tx.bankAccountId,
            accountNickname:
                bankNicknameById[tx.bankAccountId] ?? 'Unknown account',
            kind: tx.kind,
            amountPaise: tx.amountPaise,
            merchant: tx.merchant,
            beneficiary: tx.beneficiary,
            category: tx.category,
            transactionAt: tx.transactionAt,
            source: tx.source,
            referenceNumber: tx.referenceNumber,
            isReviewed: tx.isReviewed,
            notes: tx.notes,
            location: tx.location,
            createdAt: tx.createdAt,
          ),
      ],
      billingCycles: billingCycles,
      categories: categoryNames,
      accounts: [
        for (final card in cards)
          ReportAccountRow(
            id: card.id,
            kind: 'credit_card',
            bank: card.bank,
            nickname: card.nickname,
            lastFourDigits: card.lastFourDigits,
            isArchived: card.isArchived,
          ),
        for (final account in bankAccountRows)
          ReportAccountRow(
            id: account.id,
            kind: 'bank_account',
            bank: account.bank,
            nickname: account.nickname,
            lastFourDigits: account.lastFourDigits,
            isArchived: account.isArchived,
          ),
      ],
      monthlyBudget: monthlyProgress == null
          ? null
          : ReportMonthlyBudgetRow(
              limitPaise: monthlyProgress.limitPaise,
              spentPaise: monthlyProgress.spentPaise,
              remainingPaise: monthlyProgress.remainingPaise,
              periodStart: monthlyProgress.periodStart,
              periodEnd: monthlyProgress.periodEnd,
            ),
      categoryBudgets: [
        for (final row in categoryBudgets)
          ReportCategoryBudgetRow(
            category: row.category,
            limitPaise: row.limitPaise,
          ),
      ],
      bills: [
        for (final bill in unpaidBills)
          ReportBillRow(
            cycleId: bill.cycleId,
            cardNickname: bill.cardNickname,
            dueDate: bill.dueDate,
            totalOutstandingPaise: bill.totalOutstandingPaise,
            netOutstandingPaise: bill.netOutstandingPaise,
            status: bill.status.name,
          ),
      ],
      analytics: analyticsSnapshot,
      recoverablesByPerson: recoverablesByPerson,
    );
  }
}
