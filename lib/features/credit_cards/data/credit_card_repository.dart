import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_assignment.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_generation.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_status.dart';
import 'package:spendsense/features/billing_cycles/engine/due_date.dart';

class NewCreditCard {
  const NewCreditCard({
    required this.bank,
    required this.lastFourDigits,
    required this.nickname,
    required this.colorValue,
    required this.iconName,
    this.network,
    this.creditLimitPaise,
    this.notes,
  });

  final String bank;
  final String lastFourDigits;
  final String nickname;
  final String? network;
  final int? creditLimitPaise;
  final int colorValue;
  final String iconName;
  final String? notes;
}

class CreditCardRepository {
  CreditCardRepository(this._database);

  final AppDatabase _database;

  Future<int> create(NewCreditCard card) {
    return _database
        .into(_database.creditCards)
        .insert(
          CreditCardsCompanion.insert(
            bank: card.bank,
            lastFourDigits: card.lastFourDigits,
            nickname: card.nickname,
            network: Value(card.network),
            creditLimitPaise: Value(card.creditLimitPaise),
            colorValue: card.colorValue,
            iconName: card.iconName,
            notes: Value(card.notes),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<CreditCard?> getById(int id) {
    return (_database.select(_database.creditCards)
          ..where((card) => card.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<CreditCard>> listActive() {
    return (_database.select(_database.creditCards)
          ..where((card) => card.isArchived.equals(false))
          ..orderBy([(card) => OrderingTerm.asc(card.nickname)]))
        .get();
  }

  Future<void> configureBilling({
    required int cardId,
    required int billDayOfMonth,
    required int dueDateOffsetDays,
    required DateTime historyFrom,
    required DateTime historyTo,
  }) async {
    await (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(
      CreditCardsCompanion(
        billDayOfMonth: Value(billDayOfMonth),
        dueDateOffsetDays: Value(dueDateOffsetDays),
      ),
    );

    final periods = generateBillingCyclesBetween(
      from: historyFrom,
      to: historyTo,
      billDayOfMonth: billDayOfMonth,
    );

    final now = DateTime.now();
    await _deduplicateBillingCyclesForCard(cardId);

    final existingCycles = await listCycles(cardId);
    final existingPeriods = {
      for (final cycle in existingCycles)
        _cyclePeriodKey(cycle.startDate, cycle.endDate): cycle,
    };

    await _database.batch((batch) {
      for (final period in periods) {
        if (existingPeriods.containsKey(
          _cyclePeriodKey(period.startDate, period.endDate),
        )) {
          continue;
        }

        final billGenerated = shouldGenerateBill(
          cycleEndDate: period.endDate,
          asOf: now,
        );
        final dueDate = billGenerated
            ? calculateDueDate(
                billDate: period.endDate,
                dueDateOffsetDays: dueDateOffsetDays,
              )
            : null;

        batch.insert(
          _database.billingCycles,
          BillingCyclesCompanion.insert(
            creditCardId: cardId,
            startDate: period.startDate,
            endDate: period.endDate,
            billGenerated: Value(billGenerated),
            dueDate: Value(dueDate),
          ),
        );
      }
    });

    await _assignBillingCyclesToExistingTransactions(cardId);
  }

  Future<void> updateCreditLimit({
    required int cardId,
    int? creditLimitPaise,
  }) {
    return (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(
      CreditCardsCompanion(
        creditLimitPaise: Value(creditLimitPaise),
        creditLimitPoolId: const Value(null),
      ),
    );
  }

  Future<void> updateNetwork({
    required int cardId,
    String? network,
  }) {
    return (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(
      CreditCardsCompanion(
        network: Value(network),
      ),
    );
  }

  Future<void> assignCreditLimitPool({
    required int cardId,
    int? creditLimitPoolId,
  }) {
    return (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(
      CreditCardsCompanion(
        creditLimitPoolId: Value(creditLimitPoolId),
        creditLimitPaise: const Value(null),
      ),
    );
  }

  Future<void> clearCreditLimitSettings({required int cardId}) {
    return (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(
      const CreditCardsCompanion(
        creditLimitPaise: Value(null),
        creditLimitPoolId: Value(null),
      ),
    );
  }

  Future<void> updateBillingSettings({
    required int cardId,
    required int billDayOfMonth,
    required int dueDateOffsetDays,
    required DateTime historyFrom,
    required DateTime historyTo,
  }) async {
    final card = await getById(cardId);
    if (card == null) {
      return;
    }

    if (card.billDayOfMonth == null) {
      await configureBilling(
        cardId: cardId,
        billDayOfMonth: billDayOfMonth,
        dueDateOffsetDays: dueDateOffsetDays,
        historyFrom: historyFrom,
        historyTo: historyTo,
      );
      return;
    }

    final billDayChanged = card.billDayOfMonth != billDayOfMonth;
    final offsetChanged = card.dueDateOffsetDays != dueDateOffsetDays;

    if (!billDayChanged && !offsetChanged) {
      return;
    }

    if (billDayChanged) {
      await configureBilling(
        cardId: cardId,
        billDayOfMonth: billDayOfMonth,
        dueDateOffsetDays: dueDateOffsetDays,
        historyFrom: historyFrom,
        historyTo: historyTo,
      );
      await _reassignAllTransactions(cardId);
      await _pruneEmptyCycles(cardId);
      return;
    }

    await (_database.update(_database.creditCards)
          ..where((row) => row.id.equals(cardId)))
        .write(
      CreditCardsCompanion(
        dueDateOffsetDays: Value(dueDateOffsetDays),
      ),
    );
    await _refreshDueDates(cardId, dueDateOffsetDays);
  }

  Future<void> _reassignAllTransactions(int cardId) async {
    final transactions = await (_database.select(_database.cardTransactions)
          ..where((tx) => tx.creditCardId.equals(cardId)))
        .get();

    for (final transaction in transactions) {
      final cycleId = await findBillingCycleIdForTransaction(
        cardId: cardId,
        transactionAt: transaction.transactionAt,
      );

      await (_database.update(_database.cardTransactions)
            ..where((tx) => tx.id.equals(transaction.id)))
          .write(CardTransactionsCompanion(billingCycleId: Value(cycleId)));
    }
  }

  Future<void> _refreshDueDates(int cardId, int dueDateOffsetDays) async {
    final cycles = await listCycles(cardId);
    for (final cycle in cycles) {
      if (!cycle.billGenerated) {
        continue;
      }

      final dueDate = calculateDueDate(
        billDate: cycle.endDate,
        dueDateOffsetDays: dueDateOffsetDays,
      );

      await (_database.update(_database.billingCycles)
            ..where((row) => row.id.equals(cycle.id)))
          .write(BillingCyclesCompanion(dueDate: Value(dueDate)));
    }
  }

  Future<void> _pruneEmptyCycles(int cardId) async {
    final cycles = await listCycles(cardId);

    for (final cycle in cycles) {
      if (cycle.paymentsAppliedPaise > 0) {
        continue;
      }

      final transactionCount = await (_database.selectOnly(
        _database.cardTransactions,
      )
            ..addColumns([_database.cardTransactions.id.count()])
            ..where(_database.cardTransactions.billingCycleId.equals(cycle.id)))
          .map((row) => row.read(_database.cardTransactions.id.count()) ?? 0)
          .getSingle();

      if (transactionCount == 0) {
        await (_database.delete(_database.billingCycles)
              ..where((row) => row.id.equals(cycle.id)))
            .go();
      }
    }
  }

  String _cyclePeriodKey(DateTime startDate, DateTime endDate) {
    return '${startDate.toIso8601String()}|${endDate.toIso8601String()}';
  }

  Future<void> _deduplicateBillingCyclesForCard(int cardId) async {
    final cycles = await listCycles(cardId);
    final grouped = <String, List<BillingCycle>>{};

    for (final cycle in cycles) {
      final key = _cyclePeriodKey(cycle.startDate, cycle.endDate);
      grouped.putIfAbsent(key, () => []).add(cycle);
    }

    for (final duplicates in grouped.values) {
      if (duplicates.length <= 1) {
        continue;
      }
      await _consolidateDuplicateCycles(duplicates);
    }
  }

  Future<BillingCycle> _consolidateDuplicateCycles(
    List<BillingCycle> duplicates,
  ) async {
    final sorted = List<BillingCycle>.from(duplicates)
      ..sort((a, b) {
        final paymentCompare =
            b.paymentsAppliedPaise.compareTo(a.paymentsAppliedPaise);
        if (paymentCompare != 0) {
          return paymentCompare;
        }
        return a.id.compareTo(b.id);
      });

    final keeper = sorted.first;
    for (final duplicate in sorted.skip(1)) {
      await (_database.update(_database.cardTransactions)
            ..where((tx) => tx.billingCycleId.equals(duplicate.id)))
          .write(CardTransactionsCompanion(billingCycleId: Value(keeper.id)));

      await (_database.delete(_database.billingCycles)
            ..where((row) => row.id.equals(duplicate.id)))
          .go();
    }

    return keeper;
  }

  Future<BillingCycle?> _findCycleForPeriod({
    required int cardId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final cycles = await (_database.select(_database.billingCycles)
          ..where(
            (row) =>
                row.creditCardId.equals(cardId) &
                row.startDate.equals(startDate) &
                row.endDate.equals(endDate),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .get();

    if (cycles.isEmpty) {
      return null;
    }
    if (cycles.length == 1) {
      return cycles.first;
    }

    return _consolidateDuplicateCycles(cycles);
  }

  Future<void> _assignBillingCyclesToExistingTransactions(int cardId) async {
    final transactions = await (_database.select(_database.cardTransactions)
          ..where((tx) => tx.creditCardId.equals(cardId)))
        .get();

    for (final transaction in transactions) {
      if (transaction.billingCycleId != null) {
        continue;
      }

      final cycleId = await findBillingCycleIdForTransaction(
        cardId: cardId,
        transactionAt: transaction.transactionAt,
      );
      if (cycleId == null) {
        continue;
      }

      await (_database.update(_database.cardTransactions)
            ..where((tx) => tx.id.equals(transaction.id)))
          .write(CardTransactionsCompanion(billingCycleId: Value(cycleId)));
    }
  }

  Future<List<BillingCycle>> listCurrentCycles({DateTime? asOf}) async {
    final clock = asOf ?? DateTime.now();
    final cards = await listActive();
    final cycles = <BillingCycle>[];

    for (final card in cards) {
      final billDay = card.billDayOfMonth;
      if (billDay == null) {
        continue;
      }

      final cycle = await ensureCurrentCycle(cardId: card.id, asOf: clock);
      if (cycle != null) {
        cycles.add(cycle);
      }
    }

    return cycles;
  }

  Future<BillingCycle?> ensureCurrentCycle({
    required int cardId,
    DateTime? asOf,
  }) async {
    final card = await getById(cardId);
    final billDay = card?.billDayOfMonth;
    if (billDay == null) {
      return null;
    }

    final clock = asOf ?? DateTime.now();
    final period = billingCycleContaining(
      transactionDate: clock,
      billDayOfMonth: billDay,
    );

    final existing = await _findCycleForPeriod(
      cardId: cardId,
      startDate: period.startDate,
      endDate: period.endDate,
    );
    if (existing != null) {
      await _assignBillingCyclesToExistingTransactions(cardId);
      return existing;
    }

    final dueDateOffsetDays = card!.dueDateOffsetDays;
    final billGenerated = shouldGenerateBill(
      cycleEndDate: period.endDate,
      asOf: clock,
    );
    final dueDate = billGenerated
        ? calculateDueDate(
            billDate: period.endDate,
            dueDateOffsetDays: dueDateOffsetDays ?? 18,
          )
        : null;

    final cycleId = await _database.into(_database.billingCycles).insert(
          BillingCyclesCompanion.insert(
            creditCardId: cardId,
            startDate: period.startDate,
            endDate: period.endDate,
            billGenerated: Value(billGenerated),
            dueDate: Value(dueDate),
          ),
        );

    await _assignBillingCyclesToExistingTransactions(cardId);
    return findCycleById(cycleId);
  }

  Future<BillingCycle?> findCycleById(int cycleId) {
    return (_database.select(_database.billingCycles)
          ..where((cycle) => cycle.id.equals(cycleId)))
        .getSingleOrNull();
  }

  Future<List<BillingCycle>> listCyclesForActiveCards() async {
    final cards = await listActive();
    final cycles = <BillingCycle>[];
    for (final card in cards) {
      cycles.addAll(await listCycles(card.id));
    }
    return cycles;
  }

  Future<List<BillingCycle>> listCycles(int cardId) {
    return (_database.select(_database.billingCycles)
          ..where((cycle) => cycle.creditCardId.equals(cardId))
          ..orderBy([(cycle) => OrderingTerm.desc(cycle.endDate)]))
        .get();
  }

  Future<List<CreditCard>> listArchived() {
    return (_database.select(_database.creditCards)
          ..where((card) => card.isArchived.equals(true))
          ..orderBy([(card) => OrderingTerm.asc(card.nickname)]))
        .get();
  }

  Future<void> archive(int cardId) async {
    await (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(const CreditCardsCompanion(isArchived: Value(true)));
  }

  Future<void> unarchive(int cardId) async {
    await (_database.update(_database.creditCards)
          ..where((card) => card.id.equals(cardId)))
        .write(const CreditCardsCompanion(isArchived: Value(false)));
  }

  Future<void> deletePermanently(int cardId) async {
    final transactionIds = await (_database.select(_database.cardTransactions)
          ..where((row) => row.creditCardId.equals(cardId)))
        .map((row) => row.id)
        .get();

    await _database.batch((batch) {
      for (final transactionId in transactionIds) {
        batch.deleteWhere(
          _database.cardTransactionTags,
          (row) => row.cardTransactionId.equals(transactionId),
        );
        batch.deleteWhere(
          _database.cardTransactionReceipts,
          (row) => row.cardTransactionId.equals(transactionId),
        );
        batch.deleteWhere(
          _database.recoveryLinks,
          (row) =>
              row.creditTransactionId.equals(transactionId) |
              row.recoverableTransactionId.equals(transactionId),
        );
        batch.deleteWhere(
          _database.transactionLinks,
          (row) =>
              row.cardTransactionId.equals(transactionId) |
              row.linkedCardTransactionId.equals(transactionId),
        );
      }
      batch.deleteWhere(
        _database.cardTransactions,
        (row) => row.creditCardId.equals(cardId),
      );
      batch.deleteWhere(
        _database.billingCycles,
        (row) => row.creditCardId.equals(cardId),
      );
      batch.deleteWhere(
        _database.creditCards,
        (row) => row.id.equals(cardId),
      );
    });
  }

  Future<CreditCard?> findByBankAndLastFour({
    required String bank,
    required String lastFourDigits,
  }) {
    return (_database.select(_database.creditCards)
          ..where(
            (card) =>
                card.bank.equals(bank) &
                card.lastFourDigits.equals(lastFourDigits),
          ))
        .getSingleOrNull();
  }

  Future<int> autoCreateFromSms({
    required String bank,
    required String lastFourDigits,
  }) {
    return create(
      NewCreditCard(
        bank: bank,
        lastFourDigits: lastFourDigits,
        nickname: '$bank ••$lastFourDigits',
        colorValue: 0xFF00695C,
        iconName: 'credit_card',
      ),
    );
  }

  Future<int?> findBillingCycleIdForTransaction({
    required int cardId,
    required DateTime transactionAt,
  }) async {
    final card = await getById(cardId);
    final billDay = card?.billDayOfMonth;
    if (billDay == null) {
      return null;
    }

    final period = billingCycleContaining(
      transactionDate: transactionAt,
      billDayOfMonth: billDay,
    );

    final cycle = await _findCycleForPeriod(
      cardId: cardId,
      startDate: period.startDate,
      endDate: period.endDate,
    );

    return cycle?.id;
  }

  Future<void> setCyclePaymentsApplied({
    required int cycleId,
    required int paymentsAppliedPaise,
  }) {
    return (_database.update(_database.billingCycles)
          ..where((row) => row.id.equals(cycleId)))
        .write(
      BillingCyclesCompanion(
        paymentsAppliedPaise: Value(paymentsAppliedPaise),
      ),
    );
  }
}
