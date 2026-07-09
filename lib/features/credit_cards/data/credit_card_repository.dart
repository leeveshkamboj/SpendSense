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
    await _database.batch((batch) {
      for (final period in periods) {
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

    final cycle = await (_database.select(_database.billingCycles)
          ..where(
            (row) =>
                row.creditCardId.equals(cardId) &
                row.startDate.equals(period.startDate) &
                row.endDate.equals(period.endDate),
          ))
        .getSingleOrNull();

    return cycle?.id;
  }
}
