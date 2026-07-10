class BillWidgetItem {
  const BillWidgetItem({
    required this.creditCardId,
    required this.cycleId,
    required this.cardNickname,
    required this.dueDate,
    required this.netOutstandingPaise,
    required this.colorValue,
  });

  final int creditCardId;
  final int cycleId;
  final String cardNickname;
  final DateTime? dueDate;
  final int netOutstandingPaise;
  final int colorValue;
}

class BillsWidgetSnapshot {
  const BillsWidgetSnapshot({required this.bills});

  final List<BillWidgetItem> bills;
}
