import 'package:spendsense/features/sms_capture/domain/parsed_card_credit.dart';

final _hdfcRefundPattern = RegExp(
  r'Credit of Rs\.?(\d+(?:\.\d+)?) received on HDFC Bank Card (\d{4}) (?:for|towards) (.+?) On '
  r'(\d{4})-(\d{2})-(\d{2})',
  caseSensitive: false,
);

final _hdfcPaymentPattern = RegExp(
  r'Payment of Rs\.?(\d+(?:\.\d+)?) received (?:towards|on) HDFC Bank Card (\d{4}) On '
  r'(\d{4})-(\d{2})-(\d{2})',
  caseSensitive: false,
);

ParsedCardCredit? parseHdfcCardCreditSms(String sms) {
  final normalized = sms.replaceAll(RegExp(r'\s+'), ' ').trim();

  final refundMatch = _hdfcRefundPattern.firstMatch(normalized);
  if (refundMatch != null) {
    return ParsedCardCredit(
      kind: ParsedCardCreditKind.refund,
      amountPaise: _rupeesToPaise(refundMatch.group(1)!),
      bank: 'HDFC',
      lastFourDigits: refundMatch.group(2)!,
      merchant: refundMatch.group(3)!.trim(),
      transactionAt: DateTime(
        int.parse(refundMatch.group(4)!),
        int.parse(refundMatch.group(5)!),
        int.parse(refundMatch.group(6)!),
      ),
      rawSms: sms,
    );
  }

  final paymentMatch = _hdfcPaymentPattern.firstMatch(normalized);
  if (paymentMatch != null) {
    return ParsedCardCredit(
      kind: ParsedCardCreditKind.cardPayment,
      amountPaise: _rupeesToPaise(paymentMatch.group(1)!),
      bank: 'HDFC',
      lastFourDigits: paymentMatch.group(2)!,
      transactionAt: DateTime(
        int.parse(paymentMatch.group(3)!),
        int.parse(paymentMatch.group(4)!),
        int.parse(paymentMatch.group(5)!),
      ),
      rawSms: sms,
    );
  }

  return null;
}

int _rupeesToPaise(String rupees) {
  final value = double.parse(rupees);
  return (value * 100).round();
}
