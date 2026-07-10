/// Strips bank SMS boilerplate from a parsed merchant string.
String cleanParsedMerchant(String merchant) {
  var value = merchant.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (value.isEmpty) {
    return value;
  }

  final cutoffs = <RegExp>[
    RegExp(r'\s+by UPI\b', caseSensitive: false),
    RegExp(r'\s+On\s+\d', caseSensitive: false),
    RegExp(r'\s+Not You\?', caseSensitive: false),
    RegExp(r'\s+Call\s+\d', caseSensitive: false),
    RegExp(r'\s+SMS BLOCK\b', caseSensitive: false),
  ];

  for (final pattern in cutoffs) {
    final match = pattern.firstMatch(value);
    if (match != null && match.start > 0) {
      value = value.substring(0, match.start).trim();
      break;
    }
  }

  return value;
}

/// Human-readable merchant label for lists and dashboards.
String formatMerchantLabel(String raw) {
  var value = cleanParsedMerchant(raw);
  if (value.isEmpty) {
    return 'Transaction';
  }

  if (RegExp(r'^paytmqr', caseSensitive: false).hasMatch(value)) {
    return 'Paytm';
  }
  if (RegExp(r'^phonepe', caseSensitive: false).hasMatch(value)) {
    return 'PhonePe';
  }
  if (RegExp(r'^gpay-', caseSensitive: false).hasMatch(value)) {
    return 'Google Pay';
  }

  if (value.contains('@')) {
    final localPart = value.split('@').first;
    if (localPart.toLowerCase().startsWith('paytm')) {
      return 'Paytm';
    }
    return _titleCase(localPart.replaceAll('.', ' '));
  }

  return _titleCase(value);
}

String merchantInitial(String label) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed[0].toUpperCase();
}

String _titleCase(String value) {
  final words = value.split(RegExp(r'\s+'));
  final titled = words
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
  return titled.isEmpty ? value : titled;
}
