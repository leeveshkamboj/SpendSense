import 'package:spendsense/features/linking/domain/transfer_candidate.dart';

const transferPairingWindow = Duration(minutes: 5);

TransferPair? findTransferPair({
  required TransferCandidate incoming,
  required List<TransferCandidate> candidates,
  Duration window = transferPairingWindow,
}) {
  final oppositeKind = incoming.kind == TransferSideKind.debit
      ? TransferSideKind.credit
      : TransferSideKind.debit;

  TransferCandidate? bestMatch;
  var bestDelta = window + const Duration(seconds: 1);

  for (final candidate in candidates) {
    if (candidate.isLinked) continue;
    if (candidate.transactionId == incoming.transactionId) continue;
    if (candidate.accountId == incoming.accountId) continue;
    if (candidate.kind != oppositeKind) continue;
    if (candidate.amountPaise != incoming.amountPaise) continue;

    final delta = incoming.transactionAt
        .difference(candidate.transactionAt)
        .abs();
    if (delta > window) continue;

    if (delta < bestDelta) {
      bestDelta = delta;
      bestMatch = candidate;
    }
  }

  if (bestMatch == null) return null;
  return TransferPair(pairedTransactionId: bestMatch.transactionId);
}
