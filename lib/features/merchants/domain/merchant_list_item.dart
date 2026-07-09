class MerchantListItem {
  const MerchantListItem({
    required this.rawName,
    this.displayName,
    required this.defaultCategory,
    required this.tags,
  });

  final String rawName;
  final String? displayName;
  final String defaultCategory;
  final List<String> tags;

  String get title => displayName?.trim().isNotEmpty == true
      ? displayName!.trim()
      : rawName;
}
