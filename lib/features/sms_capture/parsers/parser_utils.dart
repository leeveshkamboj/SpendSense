String normalizeSms(String sms) {
  final plain = deunicodeSms(sms);
  return plain.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String deunicodeSms(String sms) {
  final buffer = StringBuffer();
  for (final codePoint in sms.runes) {
    final mapped = _mapFancyUnicode(codePoint);
    buffer.writeCharCode(mapped ?? codePoint);
  }
  return buffer.toString();
}

int? _mapFancyUnicode(int codePoint) {
  const letterBlocks = <int>[
    0x1D400, // bold
    0x1D434, // italic
    0x1D468, // bold italic
    0x1D56C, // sans-serif cap
    0x1D5A0, // sans-serif small
    0x1D5D4, // sans-serif bold cap
    0x1D5EE, // sans-serif bold small
    0x1D608, // sans-serif italic cap
    0x1D622, // sans-serif italic small
    0x1D63C, // sans-serif bold italic cap
    0x1D656, // sans-serif bold italic small
    0x1D670, // monospace cap
    0x1D68A, // monospace small
  ];

  for (final start in letterBlocks) {
    final offset = codePoint - start;
    if (offset >= 0 && offset < 26) {
      return 0x41 + offset;
    }
    if (offset >= 26 && offset < 52) {
      return 0x61 + (offset - 26);
    }
  }

  if (codePoint >= 0xFF21 && codePoint <= 0xFF3A) {
    return 0x41 + (codePoint - 0xFF21);
  }
  if (codePoint >= 0xFF41 && codePoint <= 0xFF5A) {
    return 0x61 + (codePoint - 0xFF41);
  }

  return null;
}

int rupeesToPaise(String rupees) {
  final normalized = rupees.replaceAll(',', '');
  return (double.parse(normalized) * 100).round();
}

DateTime? parseSmsDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final iso = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (iso != null) {
    return DateTime(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }

  final dmy = RegExp(r'(\d{2})-(\d{2})-(\d{2})').firstMatch(value);
  if (dmy != null) {
    final year = 2000 + int.parse(dmy.group(3)!);
    return DateTime(
      year,
      int.parse(dmy.group(2)!),
      int.parse(dmy.group(1)!),
    );
  }

  final dayMonth = RegExp(r'^(\d{2})-(\d{2})$').firstMatch(value);
  if (dayMonth != null) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      int.parse(dayMonth.group(2)!),
      int.parse(dayMonth.group(1)!),
    );
  }

  final compact = RegExp(r'^(\d{1,2})([A-Za-z]{3})(\d{2})$').firstMatch(value);
  if (compact != null) {
    final month = _monthFromAbbreviation(compact.group(2)!);
    if (month != null) {
      return DateTime(
        2000 + int.parse(compact.group(3)!),
        month,
        int.parse(compact.group(1)!),
      );
    }
  }

  return null;
}

int? _monthFromAbbreviation(String value) {
  const months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };
  return months[value.toLowerCase()];
}

DateTime? parseSmsDateFromSuffix(String sms) {
  final matches = RegExp(
    r'On\s+(\d{2}-\d{2}(?:-\d{2,4})?)',
    caseSensitive: false,
  ).allMatches(sms);
  if (matches.isEmpty) {
    return null;
  }
  return parseSmsDate(matches.last.group(1));
}
