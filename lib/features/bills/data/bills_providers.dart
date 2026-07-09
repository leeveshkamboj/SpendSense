import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/data/bills_repository.dart';
import 'package:spendsense/features/bills/domain/bill_summary.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final billsRepositoryProvider = Provider<BillsRepository>((ref) {
  return BillsRepository(
    creditCards: ref.watch(creditCardRepositoryProvider),
    transactions: ref.watch(cardTransactionRepositoryProvider),
    recoverables: ref.watch(recoverableRepositoryProvider),
  );
});

final unpaidBillsProvider = FutureProvider<List<BillSummary>>((ref) {
  return ref.watch(billsRepositoryProvider).listUnpaidBills(
        asOf: DateTime.now(),
      );
});
