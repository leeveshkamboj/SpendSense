import 'package:intl/intl.dart';

final _indianCurrencyWhole = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

final _indianCurrencyDecimal = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

String formatPaise(int paise) {
  final rupees = paise / 100;
  if (rupees.truncateToDouble() == rupees) {
    return _indianCurrencyWhole.format(rupees);
  }
  return _indianCurrencyDecimal.format(rupees);
}

String formatRupees(double rupees) {
  if (rupees.truncateToDouble() == rupees) {
    return _indianCurrencyWhole.format(rupees);
  }
  return _indianCurrencyDecimal.format(rupees);
}
