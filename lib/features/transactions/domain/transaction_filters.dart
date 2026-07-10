import 'package:spendsense/core/database/database.dart';

class TransactionFilters {
  const TransactionFilters({
    this.minAmountPaise,
    this.maxAmountPaise,
    this.dateFrom,
    this.dateTo,
    this.category,
    this.kind,
    this.source,
    this.reviewed,
    this.hasNotes,
    this.hasReceipt,
    this.recurringOnly = false,
  });

  final int? minAmountPaise;
  final int? maxAmountPaise;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? category;
  final String? kind;
  final String? source;
  final bool? reviewed;
  final bool? hasNotes;
  final bool? hasReceipt;
  final bool recurringOnly;

  bool get isEmpty {
    return minAmountPaise == null &&
        maxAmountPaise == null &&
        dateFrom == null &&
        dateTo == null &&
        category == null &&
        kind == null &&
        source == null &&
        reviewed == null &&
        hasNotes == null &&
        hasReceipt == null &&
        !recurringOnly;
  }

  int get activeCount {
    var count = 0;
    if (minAmountPaise != null) count++;
    if (maxAmountPaise != null) count++;
    if (dateFrom != null) count++;
    if (dateTo != null) count++;
    if (category != null) count++;
    if (kind != null) count++;
    if (source != null) count++;
    if (reviewed != null) count++;
    if (hasNotes != null) count++;
    if (hasReceipt != null) count++;
    if (recurringOnly) count++;
    return count;
  }

  TransactionFilters copyWith({
    int? minAmountPaise,
    int? maxAmountPaise,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? category,
    String? kind,
    String? source,
    bool? reviewed,
    bool? hasNotes,
    bool? hasReceipt,
    bool? recurringOnly,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearCategory = false,
    bool clearKind = false,
    bool clearSource = false,
    bool clearReviewed = false,
    bool clearHasNotes = false,
    bool clearHasReceipt = false,
  }) {
    return TransactionFilters(
      minAmountPaise: clearMinAmount ? null : (minAmountPaise ?? this.minAmountPaise),
      maxAmountPaise: clearMaxAmount ? null : (maxAmountPaise ?? this.maxAmountPaise),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      category: clearCategory ? null : (category ?? this.category),
      kind: clearKind ? null : (kind ?? this.kind),
      source: clearSource ? null : (source ?? this.source),
      reviewed: clearReviewed ? null : (reviewed ?? this.reviewed),
      hasNotes: clearHasNotes ? null : (hasNotes ?? this.hasNotes),
      hasReceipt: clearHasReceipt ? null : (hasReceipt ?? this.hasReceipt),
      recurringOnly: recurringOnly ?? this.recurringOnly,
    );
  }
}

bool matchesTransactionFilters({
  required CardTransaction transaction,
  required TransactionFilters filters,
  Set<int> transactionIdsWithReceipts = const {},
}) {
  if (filters.recurringOnly && !transaction.isRecurring) {
    return false;
  }

  if (filters.minAmountPaise != null &&
      transaction.amountPaise < filters.minAmountPaise!) {
    return false;
  }

  if (filters.maxAmountPaise != null &&
      transaction.amountPaise > filters.maxAmountPaise!) {
    return false;
  }

  if (filters.dateFrom != null) {
    final from = DateTime(
      filters.dateFrom!.year,
      filters.dateFrom!.month,
      filters.dateFrom!.day,
    );
    final txnDate = DateTime(
      transaction.transactionAt.year,
      transaction.transactionAt.month,
      transaction.transactionAt.day,
    );
    if (txnDate.isBefore(from)) {
      return false;
    }
  }

  if (filters.dateTo != null) {
    final to = DateTime(
      filters.dateTo!.year,
      filters.dateTo!.month,
      filters.dateTo!.day,
      23,
      59,
      59,
      999,
    );
    if (transaction.transactionAt.isAfter(to)) {
      return false;
    }
  }

  if (filters.category != null && transaction.category != filters.category) {
    return false;
  }

  if (filters.kind != null && transaction.kind != filters.kind) {
    return false;
  }

  if (filters.source != null && transaction.source != filters.source) {
    return false;
  }

  if (filters.reviewed != null && transaction.isReviewed != filters.reviewed) {
    return false;
  }

  if (filters.hasNotes == true &&
      (transaction.notes == null || transaction.notes!.trim().isEmpty)) {
    return false;
  }
  if (filters.hasNotes == false &&
      transaction.notes != null &&
      transaction.notes!.trim().isNotEmpty) {
    return false;
  }

  final hasReceipt = transactionIdsWithReceipts.contains(transaction.id);
  if (filters.hasReceipt == true && !hasReceipt) {
    return false;
  }
  if (filters.hasReceipt == false && hasReceipt) {
    return false;
  }

  return true;
}
