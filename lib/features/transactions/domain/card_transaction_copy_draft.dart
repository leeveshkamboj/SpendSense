class CardTransactionCopyDraft {
  const CardTransactionCopyDraft({
    required this.creditCardId,
    required this.merchant,
    required this.category,
    required this.tags,
    this.kind = 'expense',
  });

  final int creditCardId;
  final String merchant;
  final String? category;
  final List<String> tags;
  final String kind;
}
