String normalizeSms(String sms) => sms.replaceAll(RegExp(r'\s+'), ' ').trim();

int rupeesToPaise(String rupees) => (double.parse(rupees) * 100).round();

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

  return null;
}
