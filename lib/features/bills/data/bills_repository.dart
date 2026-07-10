import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_kind_codec.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';
import 'package:spendsense/features/billing_cycles/engine/overpayment.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/bills/domain/bill_sorting.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/bills/domain/net_outstanding.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';
import 'package:spendsense/features/recoverables/data/recoverable_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class BillsRepository {
  BillsRepository({
    required CreditCardRepository creditCards,
    required CardTransactionRepository transactions,
    required RecoverableRepository recoverables,
  })  : _creditCards = creditCards,
        _transactions = transactions,
        _recoverables = recoverables;

  final CreditCardRepository _creditCards;
  final CardTransactionRepository _transactions;
  final RecoverableRepository _recoverables;

  Future<List<BillSummary>> listUnpaidBills({
    required DateTime asOf,
    int historyMonths = defaultSmsImportWindowMonths,
  }) async {
    final activeCards = await _creditCards.listActive();
    final bills = <BillSummary>[];
    final historyCutoff = billingHistoryStart(now: asOf, months: historyMonths);

    for (final card in activeCards) {
      final cycles = await _creditCards.listCycles(card.id);
      for (final cycle in cycles) {
        if (!cycle.billGenerated) {
          continue;
        }
        if (cycle.endDate.isBefore(historyCutoff)) {
          continue;
        }

        final cycleTransactions =
            await _transactions.listForBillingCycleInclusive(
          cardId: card.id,
          cycle: cycle,
        );
        final billAmountPaise = calculateBillAmount(
          cycleTransactions.map(cardTransactionLineFrom),
        );
        final summary = summarizeBillingCycle(
          cycle: cycle,
          billAmountPaise: billAmountPaise,
          asOf: asOf,
        );

        if (summary.status == BillingCycleStatus.paid) {
          continue;
        }

        final totalOutstanding = calculateTotalOutstanding(
          billAmountPaise: billAmountPaise,
          paymentsAppliedPaise: cycle.paymentsAppliedPaise,
        );
        final unsettledRecoverable =
            await _recoverables.unsettledRecoverablePaiseForCycle(cycle.id);

        bills.add(
          BillSummary(
            cycleId: cycle.id,
            creditCardId: card.id,
            cardNickname: card.nickname,
            cardNetwork: card.network,
            colorValue: card.colorValue,
            dueDate: cycle.dueDate,
            billAmountPaise: billAmountPaise,
            paymentsAppliedPaise: cycle.paymentsAppliedPaise,
            totalOutstandingPaise: totalOutstanding,
            netOutstandingPaise: calculateNetOutstanding(
              totalOutstandingPaise: totalOutstanding,
              unsettledRecoverablePaise: unsettledRecoverable,
            ),
            status: summary.status,
          ),
        );
      }
    }

    return sortBills(bills);
  }

  Future<void> recordManualPayment({
    required int cycleId,
    required int paymentPaise,
  }) async {
    if (paymentPaise <= 0) {
      throw ArgumentError.value(paymentPaise, 'paymentPaise', 'must be positive');
    }

    final cycle = await _creditCards.findCycleById(cycleId);
    if (cycle == null) {
      throw StateError('Billing cycle $cycleId not found');
    }

    final billAmountPaise = await _billAmountForCycle(cycleId);
    final outstanding = calculateTotalOutstanding(
      billAmountPaise: billAmountPaise,
      paymentsAppliedPaise: cycle.paymentsAppliedPaise,
    );
    if (outstanding <= 0) {
      return;
    }

    final allocation = allocatePayment(
      outstandingPaise: outstanding,
      paymentPaise: paymentPaise,
    );

    await _creditCards.setCyclePaymentsApplied(
      cycleId: cycleId,
      paymentsAppliedPaise:
          cycle.paymentsAppliedPaise + allocation.appliedToCyclePaise,
    );
  }

  Future<void> markBillPaidInFull({required int cycleId}) async {
    final cycle = await _creditCards.findCycleById(cycleId);
    if (cycle == null) {
      throw StateError('Billing cycle $cycleId not found');
    }

    final billAmountPaise = await _billAmountForCycle(cycleId);
    await _creditCards.setCyclePaymentsApplied(
      cycleId: cycleId,
      paymentsAppliedPaise: billAmountPaise,
    );
  }

  Future<int> _billAmountForCycle(int cycleId) async {
    final cycle = await _creditCards.findCycleById(cycleId);
    if (cycle == null) {
      return 0;
    }

    final cycleTransactions = await _transactions.listForBillingCycleInclusive(
      cardId: cycle.creditCardId,
      cycle: cycle,
    );
    return calculateBillAmount(cycleTransactions.map(cardTransactionLineFrom));
  }
}
