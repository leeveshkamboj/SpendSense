import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';

const _duplicateWindow = Duration(minutes: 5);

bool matchesExistingCapture({
  required CapturedTransactionSnapshot incoming,
  required Iterable<CapturedTransactionSnapshot> existing,
}) {
  for (final candidate in existing) {
    if (!_sameAccount(incoming, candidate)) {
      continue;
    }

    if (incoming.referenceNumber != null &&
        candidate.referenceNumber == incoming.referenceNumber) {
      return true;
    }

    if (incoming.referenceNumber == null && candidate.referenceNumber == null) {
      final sameAmountAndMerchant = candidate.amountPaise == incoming.amountPaise &&
          candidate.merchant == incoming.merchant;
      final withinWindow = incoming.transactionAt
          .difference(candidate.transactionAt)
          .abs()
          .compareTo(_duplicateWindow) <= 0;

      if (sameAmountAndMerchant && withinWindow) {
        return true;
      }
    }
  }

  return false;
}

bool _sameAccount(
  CapturedTransactionSnapshot a,
  CapturedTransactionSnapshot b,
) {
  if (a.creditCardId != null && a.creditCardId == b.creditCardId) {
    return true;
  }
  if (a.bankAccountId != null && a.bankAccountId == b.bankAccountId) {
    return true;
  }
  return false;
}
