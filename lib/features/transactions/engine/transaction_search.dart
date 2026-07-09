bool matchesCardTransactionSearch({
  required String merchant,
  required String? category,
  required String? referenceNumber,
  required String? notes,
  required String query,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }

  bool contains(String? value) =>
      value?.toLowerCase().contains(normalized) ?? false;

  return contains(merchant) ||
      contains(category) ||
      contains(referenceNumber) ||
      contains(notes);
}

bool matchesBankTransactionSearch({
  required String? merchant,
  required String? beneficiary,
  required String? category,
  required String? referenceNumber,
  required String? notes,
  required String query,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }

  bool contains(String? value) =>
      value?.toLowerCase().contains(normalized) ?? false;

  return contains(merchant) ||
      contains(beneficiary) ||
      contains(category) ||
      contains(referenceNumber) ||
      contains(notes);
}
