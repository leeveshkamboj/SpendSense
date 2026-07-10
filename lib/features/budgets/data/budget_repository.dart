import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/budgets/domain/budget_progress.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction_kind_codec.dart';
import 'package:spendsense/features/budgets/engine/budget_alerts.dart';
import 'package:spendsense/features/budgets/engine/budget_assignment.dart';
import 'package:spendsense/features/budgets/engine/budget_projection.dart';
import 'package:spendsense/features/budgets/engine/budget_spend.dart';
import 'package:spendsense/features/analytics/engine/analytics_period.dart'
    as analytics_period;
import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class BudgetRepository {
  BudgetRepository({
    required AppDatabase database,
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
  })  : _database = database,
        _creditCards = creditCards,
        _cardTransactions = cardTransactions;

  final AppDatabase _database;
  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;

  Future<void> setMonthlyLimit(int? limitPaise) async {
    final existing = await _settingsRow();
    if (existing == null) {
      await _database.into(_database.budgetSettings).insert(
            BudgetSettingsCompanion(monthlyLimitPaise: Value(limitPaise)),
          );
      return;
    }

    await (_database.update(_database.budgetSettings)
          ..where((row) => row.id.equals(existing.id)))
        .write(BudgetSettingsCompanion(monthlyLimitPaise: Value(limitPaise)));
  }

  Future<void> setCategoryBudget({
    required String category,
    required int limitPaise,
  }) async {
    final existing = await (_database.select(_database.categoryBudgets)
          ..where((row) => row.category.equals(category)))
        .getSingleOrNull();

    if (existing == null) {
      await _database.into(_database.categoryBudgets).insert(
            CategoryBudgetsCompanion.insert(
              category: category,
              limitPaise: limitPaise,
            ),
          );
      return;
    }

    await (_database.update(_database.categoryBudgets)
          ..where((row) => row.id.equals(existing.id)))
        .write(CategoryBudgetsCompanion(limitPaise: Value(limitPaise)));
  }

  Future<List<CategoryBudget>> listCategoryBudgets() async {
    final rows = await _database.select(_database.categoryBudgets).get();
    return rows
        .map((row) => CategoryBudget(category: row.category, limitPaise: row.limitPaise))
        .toList();
  }

  Future<BudgetProgressSnapshot?> monthlyProgress({required DateTime asOf}) async {
    final settings = await _settingsRow();
    final monthlyLimit = settings?.monthlyLimitPaise;
    if (monthlyLimit == null) {
      return null;
    }

    final cards = await _loadCardBillingStates(asOf);
    final periodStart = _currentPeriodStart(asOf: asOf, cards: cards);
    final billDays = cards
        .map((card) => card.billDayOfMonth)
        .whereType<int>()
        .toList();
    final periodEnd = budgetPeriodEnd(
      periodStart: periodStart,
      billDaysOfMonth: billDays,
    );

    final periodTransactions = await listBudgetPeriodTransactions(asOf: asOf);
    final spentPaise = calculatePersonalSpendPaise(periodTransactions);
    final projectedPaise = projectEndOfPeriodSpend(
      spentPaise: spentPaise,
      periodStart: periodStart,
      asOf: asOf,
      periodEnd: periodEnd,
    );

    return BudgetProgressSnapshot(
      limitPaise: monthlyLimit,
      spentPaise: spentPaise,
      projectedPaise: projectedPaise,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  Future<List<BudgetTransaction>> listBudgetPeriodTransactions({
    required DateTime asOf,
    DateTime? periodStart,
  }) async {
    final cards = await _loadCardBillingStates(asOf);
    final targetStart =
        periodStart ?? _currentPeriodStart(asOf: asOf, cards: cards);
    final transactions = await _budgetTransactions();
    final currentCycleIds = (await _creditCards.listCurrentCycles(asOf: asOf))
        .map((cycle) => cycle.id)
        .toSet();

    return transactions.where((transaction) {
      if (transaction.billingCycleId != null &&
          currentCycleIds.contains(transaction.billingCycleId)) {
        return true;
      }

      final card = cards.firstWhere(
        (row) => row.cardId == transaction.cardId,
        orElse: () => const CardBillingState(
          cardId: -1,
          billDayOfMonth: null,
          billGeneratedForCurrentCycle: false,
        ),
      );
      if (card.billDayOfMonth == null) {
        return false;
      }

      final assignedStart = budgetPeriodStartForTransaction(
        transactionDate: transaction.transactionAt!,
        billDayOfMonth: card.billDayOfMonth!,
        unifiedRolloverActive: isUnifiedRolloverActive(asOf: asOf, cards: cards),
      );
      return _sameDay(assignedStart, targetStart);
    }).toList();
  }

  Future<DateTime> currentBudgetPeriodStart({required DateTime asOf}) async {
    final cards = await _loadCardBillingStates(asOf);
    return _currentPeriodStart(asOf: asOf, cards: cards);
  }

  Future<DateTime> previousBudgetPeriodStart({required DateTime asOf}) async {
    final cards = await _loadCardBillingStates(asOf);
    final current = _currentPeriodStart(asOf: asOf, cards: cards);
    return analytics_period.previousBudgetPeriodStart(
      currentPeriodStart: current,
      cards: cards,
      asOf: asOf,
    );
  }

  Future<Set<BudgetAlertThreshold>> crossedMonthlyAlertThresholds({
    required DateTime asOf,
  }) async {
    final progress = await monthlyProgress(asOf: asOf);
    if (progress == null) {
      return const {};
    }

    final previouslyCrossed = await _crossedThresholds(
      budgetKey: 'monthly',
      periodStart: progress.periodStart,
    );

    return crossedSpendingAlertThresholds(
      spentPaise: progress.spentPaise,
      limitPaise: progress.limitPaise,
      previouslyCrossed: previouslyCrossed,
    );
  }

  Future<void> recordCrossedThresholds({
    required DateTime periodStart,
    required Set<BudgetAlertThreshold> thresholds,
  }) async {
    for (final threshold in thresholds) {
      await _database.into(_database.budgetAlertCrossings).insert(
            BudgetAlertCrossingsCompanion.insert(
              budgetKey: 'monthly',
              threshold: threshold.name,
              periodStart: periodStart,
            ),
          );
    }
  }

  Future<BudgetAlertThresholdConfig> alertThresholds() async {
    final settings = await _settingsRow();
    return BudgetAlertThresholdConfig(
      seventyFive: settings?.alertThreshold75 ?? 75,
      ninety: settings?.alertThreshold90 ?? 90,
      oneHundred: settings?.alertThreshold100 ?? 100,
    );
  }

  Future<void> setAlertThresholds({
    required int seventyFive,
    required int ninety,
    required int oneHundred,
  }) async {
    final existing = await _settingsRow();
    if (existing == null) {
      await _database.into(_database.budgetSettings).insert(
            BudgetSettingsCompanion(
              alertThreshold75: Value(seventyFive),
              alertThreshold90: Value(ninety),
              alertThreshold100: Value(oneHundred),
            ),
          );
      return;
    }

    await (_database.update(_database.budgetSettings)
          ..where((row) => row.id.equals(existing.id)))
        .write(
      BudgetSettingsCompanion(
        alertThreshold75: Value(seventyFive),
        alertThreshold90: Value(ninety),
        alertThreshold100: Value(oneHundred),
      ),
    );
  }

  Future<BudgetSettingRow?> _settingsRow() {
    return _database.select(_database.budgetSettings).getSingleOrNull();
  }

  Future<List<CardBillingState>> _loadCardBillingStates(DateTime asOf) async {
    final cards = await _creditCards.listActive();
    final states = <CardBillingState>[];

    for (final card in cards) {
      if (card.billDayOfMonth == null) {
        continue;
      }

      final cycle = billingCycleContaining(
        transactionDate: asOf,
        billDayOfMonth: card.billDayOfMonth!,
      );
      final currentCycle = await (_database.select(_database.billingCycles)
            ..where(
              (row) =>
                  row.creditCardId.equals(card.id) &
                  row.startDate.equals(cycle.startDate) &
                  row.endDate.equals(cycle.endDate),
            ))
          .getSingleOrNull();

      states.add(
        CardBillingState(
          cardId: card.id,
          billDayOfMonth: card.billDayOfMonth,
          billGeneratedForCurrentCycle: currentCycle?.billGenerated ?? false,
        ),
      );
    }

    return states;
  }

  Future<List<BudgetTransaction>> _budgetTransactions() async {
    final transactions = await _cardTransactions.listAll();
    return transactions
        .map(
          (tx) => BudgetTransaction(
            source: BudgetTransactionSource.creditCard,
            kind: _kindFromString(tx.kind),
            isRecoverable: tx.isRecoverable,
            amountPaise: tx.amountPaise,
            category: tx.category,
            transactionAt: tx.transactionAt,
            cardBillDayOfMonth: null,
            cardId: tx.creditCardId,
            billingCycleId: tx.billingCycleId,
          ),
        )
        .toList();
  }

  DateTime _currentPeriodStart({
    required DateTime asOf,
    required List<CardBillingState> cards,
  }) {
    final configured = cards.where((card) => card.billDayOfMonth != null).toList();
    if (configured.isEmpty) {
      return DateTime(asOf.year, asOf.month, 1);
    }

    final rollover = isUnifiedRolloverActive(asOf: asOf, cards: configured);
    final starts = configured.map((card) {
      return budgetPeriodStartForTransaction(
        transactionDate: asOf,
        billDayOfMonth: card.billDayOfMonth!,
        unifiedRolloverActive: rollover,
      );
    }).toList();

    return starts.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  Future<Set<BudgetAlertThreshold>> _crossedThresholds({
    required String budgetKey,
    required DateTime periodStart,
  }) async {
    final rows = await (_database.select(_database.budgetAlertCrossings)
          ..where(
            (row) =>
                row.budgetKey.equals(budgetKey) &
                row.periodStart.equals(periodStart),
          ))
        .get();

    return rows
        .map((row) => BudgetAlertThreshold.values.byName(row.threshold))
        .toSet();
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  BudgetTransactionKind _kindFromString(String kind) {
    return budgetTransactionKindFromString(kind);
  }
}

class CategoryBudget {
  const CategoryBudget({
    required this.category,
    required this.limitPaise,
  });

  final String category;
  final int limitPaise;
}

typedef BudgetSettingRow = BudgetSetting;

class BudgetAlertThresholdConfig {
  const BudgetAlertThresholdConfig({
    required this.seventyFive,
    required this.ninety,
    required this.oneHundred,
  });

  final int seventyFive;
  final int ninety;
  final int oneHundred;
}
