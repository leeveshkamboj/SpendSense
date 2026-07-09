import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/billing_cycles/domain/billing_cycle_status.dart';
import 'package:spendsense/features/billing_cycles/domain/card_transaction_line.dart';
import 'package:spendsense/features/billing_cycles/engine/bill_amount.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/bills/domain/bill_sorting.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/bills/domain/net_outstanding.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
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

  Future<List<BillSummary>> listUnpaidBills({required DateTime asOf}) async {
    final activeCards = await _creditCards.listActive();
    final bills = <BillSummary>[];

    for (final card in activeCards) {
      final cycles = await _creditCards.listCycles(card.id);
      for (final cycle in cycles) {
        if (!cycle.billGenerated) {
          continue;
        }

        final cycleTransactions =
            await _transactions.listForBillingCycle(cycle.id);
        final billAmountPaise = calculateBillAmount(
          cycleTransactions.map(_toTransactionLine),
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
            dueDate: cycle.dueDate,
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

  CardTransactionLine _toTransactionLine(CardTransaction transaction) {
    return CardTransactionLine(
      kind: CardTransactionKind.values.firstWhere(
        (kind) => kind.name == transaction.kind,
      ),
      amountPaise: transaction.amountPaise,
    );
  }
}
