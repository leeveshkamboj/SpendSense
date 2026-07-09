import 'package:spendsense/features/linking/domain/card_payment_candidate.dart';
import 'package:spendsense/features/linking/engine/transfer_pairing.dart';

CardPaymentPair? findCardPaymentPair({
  required CardPaymentCandidate incoming,
  required List<CardPaymentCandidate> candidates,
  Duration window = transferPairingWindow,
}) {
  final oppositeSource = incoming.source == CardPaymentSource.bankDebit
      ? CardPaymentSource.cardPayment
      : CardPaymentSource.bankDebit;

  CardPaymentCandidate? bestMatch;
  var bestDelta = window + const Duration(seconds: 1);

  for (final candidate in candidates) {
    if (candidate.isLinked) continue;
    if (candidate.transactionId == incoming.transactionId) continue;
    if (candidate.source != oppositeSource) continue;
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
  return CardPaymentPair(pairedTransactionId: bestMatch.transactionId);
}
