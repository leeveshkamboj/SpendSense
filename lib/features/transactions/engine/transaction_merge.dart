int mergedAmountPaise({
  required int survivorAmountPaise,
  required int duplicateAmountPaise,
}) {
  return survivorAmountPaise + duplicateAmountPaise;
}

String? mergedNotes({
  required String? survivorNotes,
  required String? duplicateNotes,
}) {
  final parts = [
    if (survivorNotes != null && survivorNotes.trim().isNotEmpty)
      survivorNotes.trim(),
    if (duplicateNotes != null && duplicateNotes.trim().isNotEmpty)
      duplicateNotes.trim(),
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join('\n');
}
