import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';
import 'package:spendsense/features/billing_cycles/engine/cycle_status.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/bills/domain/net_outstanding.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/linking/domain/card_payment_candidate.dart';
import 'package:spendsense/features/linking/domain/expense_candidate.dart';
import 'package:spendsense/features/linking/domain/transfer_candidate.dart';
import 'package:spendsense/features/linking/domain/unpaid_cycle_candidate.dart';
import 'package:spendsense/features/linking/engine/card_payment_assignment.dart';
import 'package:spendsense/features/linking/engine/card_payment_pairing.dart';
import 'package:spendsense/features/linking/engine/refund_linking.dart';
import 'package:spendsense/features/linking/engine/transfer_pairing.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class LinkingRepository {
  LinkingRepository({
    required AppDatabase database,
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
  })  : _database = database,
        _creditCards = creditCards,
        _cardTransactions = cardTransactions;

  final AppDatabase _database;
  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;

  Future<void> tryLinkBankTransaction({
    required int transactionId,
    required int accountId,
    required String kind,
    required int amountPaise,
    required DateTime transactionAt,
    required bool isCardPayment,
  }) async {
    if (isCardPayment) {
      await _tryLinkCardPaymentBankDebit(
        transactionId: transactionId,
        amountPaise: amountPaise,
        transactionAt: transactionAt,
      );
      return;
    }

    await _tryLinkTransfer(
      transactionId: transactionId,
      accountId: accountId,
      kind: kind,
      amountPaise: amountPaise,
      transactionAt: transactionAt,
    );
  }

  Future<int?> resolveRefundBillingCycleId({
    required int cardId,
    required String merchant,
    required int amountPaise,
  }) async {
    final expenses = await _listExpenseCandidates(cardId: cardId);
    final matchedExpenseId = findRefundExpenseMatch(
      cardId: cardId,
      merchant: merchant,
      amountPaise: amountPaise,
      expenses: expenses,
    );

    return billingCycleForRefund(
      matchedExpenseTransactionId: matchedExpenseId,
      expenses: expenses,
    );
  }

  Future<int?> findRefundOriginalExpenseId({
    required int cardId,
    required String merchant,
    required int amountPaise,
  }) async {
    final expenses = await _listExpenseCandidates(cardId: cardId);
    return findRefundExpenseMatch(
      cardId: cardId,
      merchant: merchant,
      amountPaise: amountPaise,
      expenses: expenses,
    );
  }

  Future<void> recordRefundLink({
    required int refundTransactionId,
    required int originalExpenseTransactionId,
  }) async {
    await _database.into(_database.transactionLinks).insert(
          TransactionLinksCompanion.insert(
            kind: 'refund',
            cardTransactionId: Value(refundTransactionId),
            linkedCardTransactionId: Value(originalExpenseTransactionId),
          ),
        );
  }

  Future<int?> resolveCardPaymentCycleId({
    required int cardId,
    required int paymentAmountPaise,
    required DateTime asOf,
  }) async {
    final unpaidCycles = await _listUnpaidCycleCandidates(
      cardId: cardId,
      asOf: asOf,
    );

    return selectCardPaymentCycle(
      unpaidCycles: unpaidCycles,
      paymentAmountPaise: paymentAmountPaise,
    );
  }

  Future<void> applyCardPayment({
    required int cardId,
    required int cardPaymentTransactionId,
    required int paymentAmountPaise,
    required DateTime asOf,
  }) async {
    final cycleId = await resolveCardPaymentCycleId(
      cardId: cardId,
      paymentAmountPaise: paymentAmountPaise,
      asOf: asOf,
    );
    if (cycleId == null) return;

    await (_database.update(_database.cardTransactions)
          ..where((tx) => tx.id.equals(cardPaymentTransactionId)))
        .write(CardTransactionsCompanion(billingCycleId: Value(cycleId)));

    final cycle = await (_database.select(_database.billingCycles)
          ..where((row) => row.id.equals(cycleId)))
        .getSingle();

    await (_database.update(_database.billingCycles)
          ..where((row) => row.id.equals(cycleId)))
        .write(
      BillingCyclesCompanion(
        paymentsAppliedPaise: Value(
          cycle.paymentsAppliedPaise + paymentAmountPaise,
        ),
      ),
    );
  }

  Future<void> tryLinkCardPayment({
    required int cardPaymentTransactionId,
    required int amountPaise,
    required DateTime transactionAt,
  }) async {
    await _tryLinkCardPaymentFromCardSide(
      transactionId: cardPaymentTransactionId,
      amountPaise: amountPaise,
      transactionAt: transactionAt,
    );
  }

  Future<bool> isBankTransactionLinked(int transactionId) async {
    final row = await (_database.select(_database.transactionLinks)
          ..where(
            (link) =>
                link.bankAccountTransactionId.equals(transactionId) |
                link.linkedBankAccountTransactionId.equals(transactionId),
          ))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> _tryLinkTransfer({
    required int transactionId,
    required int accountId,
    required String kind,
    required int amountPaise,
    required DateTime transactionAt,
  }) async {
    final incoming = TransferCandidate(
      transactionId: transactionId,
      accountId: accountId,
      kind: kind == 'debit' ? TransferSideKind.debit : TransferSideKind.credit,
      amountPaise: amountPaise,
      transactionAt: transactionAt,
    );

    final candidates = await _listTransferCandidates(excludeId: transactionId);
    final match = findTransferPair(
      incoming: incoming,
      candidates: candidates,
    );
    if (match == null) return;

    final debitId = kind == 'debit' ? transactionId : match.pairedTransactionId;
    final creditId =
        kind == 'credit' ? transactionId : match.pairedTransactionId;

    await _database.into(_database.transactionLinks).insert(
          TransactionLinksCompanion.insert(
            kind: 'transfer',
            bankAccountTransactionId: Value(debitId),
            linkedBankAccountTransactionId: Value(creditId),
          ),
        );

    await (_database.update(_database.bankAccountTransactions)
          ..where((tx) => tx.id.equals(debitId)))
        .write(const BankAccountTransactionsCompanion(category: Value('Transfer')));
    await (_database.update(_database.bankAccountTransactions)
          ..where((tx) => tx.id.equals(creditId)))
        .write(const BankAccountTransactionsCompanion(category: Value('Transfer')));
  }

  Future<void> _tryLinkCardPaymentBankDebit({
    required int transactionId,
    required int amountPaise,
    required DateTime transactionAt,
  }) async {
    final incoming = CardPaymentCandidate(
      transactionId: transactionId,
      source: CardPaymentSource.bankDebit,
      amountPaise: amountPaise,
      transactionAt: transactionAt,
    );

    final candidates = await _listCardPaymentCandidates(excludeId: transactionId);
    final match = findCardPaymentPair(
      incoming: incoming,
      candidates: candidates,
    );
    if (match == null) return;

    await _database.into(_database.transactionLinks).insert(
          TransactionLinksCompanion.insert(
            kind: 'card_payment',
            bankAccountTransactionId: Value(transactionId),
            linkedCardTransactionId: Value(match.pairedTransactionId),
          ),
        );
  }

  Future<void> _tryLinkCardPaymentFromCardSide({
    required int transactionId,
    required int amountPaise,
    required DateTime transactionAt,
  }) async {
    final incoming = CardPaymentCandidate(
      transactionId: transactionId,
      source: CardPaymentSource.cardPayment,
      amountPaise: amountPaise,
      transactionAt: transactionAt,
    );

    final candidates = await _listCardPaymentCandidates(excludeId: transactionId);
    final match = findCardPaymentPair(
      incoming: incoming,
      candidates: candidates,
    );
    if (match == null) return;

    await _database.into(_database.transactionLinks).insert(
          TransactionLinksCompanion.insert(
            kind: 'card_payment',
            cardTransactionId: Value(transactionId),
            linkedBankAccountTransactionId: Value(match.pairedTransactionId),
          ),
        );
  }

  Future<List<TransferCandidate>> _listTransferCandidates({
    required int excludeId,
  }) async {
    final linkedIds = await _linkedBankTransactionIds();
    final rows = await _database.select(_database.bankAccountTransactions).get();

    return [
      for (final row in rows)
        if (row.id != excludeId && !linkedIds.contains(row.id))
          TransferCandidate(
            transactionId: row.id,
            accountId: row.bankAccountId,
            kind: row.kind == 'debit'
                ? TransferSideKind.debit
                : TransferSideKind.credit,
            amountPaise: row.amountPaise,
            transactionAt: row.transactionAt,
          ),
    ];
  }

  Future<List<CardPaymentCandidate>> _listCardPaymentCandidates({
    required int excludeId,
  }) async {
    final linkedBankIds = await _linkedBankTransactionIds();
    final linkedCardIds = await _linkedCardPaymentIds();
    final bankRows = await _database.select(_database.bankAccountTransactions).get();
    final cardRows = await (_database.select(_database.cardTransactions)
          ..where((tx) => tx.kind.equals('card_payment')))
        .get();

    final candidates = <CardPaymentCandidate>[];

    for (final row in bankRows) {
      if (row.id == excludeId || linkedBankIds.contains(row.id)) continue;
      if (row.kind != 'debit') continue;
      candidates.add(
        CardPaymentCandidate(
          transactionId: row.id,
          source: CardPaymentSource.bankDebit,
          amountPaise: row.amountPaise,
          transactionAt: row.transactionAt,
          isLinked: linkedBankIds.contains(row.id),
        ),
      );
    }

    for (final row in cardRows) {
      if (row.id == excludeId || linkedCardIds.contains(row.id)) continue;
      candidates.add(
        CardPaymentCandidate(
          transactionId: row.id,
          source: CardPaymentSource.cardPayment,
          amountPaise: row.amountPaise,
          transactionAt: row.transactionAt,
          isLinked: linkedCardIds.contains(row.id),
        ),
      );
    }

    return candidates;
  }

  Future<Set<int>> _linkedBankTransactionIds() async {
    final links = await _database.select(_database.transactionLinks).get();
    return {
      for (final link in links)
        if (link.bankAccountTransactionId != null)
          link.bankAccountTransactionId!,
      for (final link in links)
        if (link.linkedBankAccountTransactionId != null)
          link.linkedBankAccountTransactionId!,
    };
  }

  Future<Set<int>> _linkedCardPaymentIds() async {
    final links = await (_database.select(_database.transactionLinks)
          ..where((link) => link.kind.equals('card_payment')))
        .get();
    return {
      for (final link in links)
        if (link.cardTransactionId != null) link.cardTransactionId!,
      for (final link in links)
        if (link.linkedCardTransactionId != null) link.linkedCardTransactionId!,
    };
  }

  Future<List<ExpenseCandidate>> _listExpenseCandidates({
    required int cardId,
  }) async {
    final rows = await (_database.select(_database.cardTransactions)
          ..where(
            (tx) => tx.creditCardId.equals(cardId) & tx.kind.equals('expense'),
          )
          ..orderBy([(tx) => OrderingTerm.asc(tx.transactionAt)]))
        .get();

    return rows
        .map(
          (row) => ExpenseCandidate(
            transactionId: row.id,
            cardId: row.creditCardId,
            merchant: row.merchant,
            amountPaise: row.amountPaise,
            billingCycleId: row.billingCycleId,
          ),
        )
        .toList();
  }

  Future<List<UnpaidCycleCandidate>> _listUnpaidCycleCandidates({
    required int cardId,
    required DateTime asOf,
  }) async {
    final cycles = await _creditCards.listCycles(cardId);
    final unpaid = <UnpaidCycleCandidate>[];

    for (final cycle in cycles) {
      if (!cycle.billGenerated) continue;

      final transactions = await _cardTransactions.listForBillingCycle(cycle.id);
      final billAmountPaise = calculateBillAmount(
        transactions.map(cardTransactionLineFrom),
      );
      final summary = summarizeBillingCycle(
        cycle: cycle,
        billAmountPaise: billAmountPaise,
        asOf: asOf,
      );
      if (summary.status == BillingCycleStatus.paid) continue;

      final outstanding = calculateTotalOutstanding(
        billAmountPaise: billAmountPaise,
        paymentsAppliedPaise: cycle.paymentsAppliedPaise,
      );

      unpaid.add(
        UnpaidCycleCandidate(
          cycleId: cycle.id,
          endDate: cycle.endDate,
          outstandingPaise: outstanding,
        ),
      );
    }

    return unpaid;
  }
}
