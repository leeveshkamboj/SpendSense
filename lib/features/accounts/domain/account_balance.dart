import 'package:spendsense/core/database/database.dart';

int computeAccountBalance({
  required int openingBalancePaise,
  required Iterable<BankAccountTransaction> transactions,
}) {
  var balance = openingBalancePaise;

  for (final transaction in transactions) {
    switch (transaction.kind) {
      case 'credit':
        balance += transaction.amountPaise;
      case 'debit':
        balance -= transaction.amountPaise;
    }
  }

  return balance;
}
