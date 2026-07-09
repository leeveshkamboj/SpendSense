import 'package:spendsense/features/billing_cycles/domain/billing_cycle_period.dart';

/// Returns the billing cycle period that contains [transactionDate].
BillingCyclePeriod billingCycleContaining({
  required DateTime transactionDate,
  required int billDayOfMonth,
}) {
  final endDate = _billDateOnOrAfter(transactionDate, billDayOfMonth);
  final previousBillDate = _billDateBefore(endDate, billDayOfMonth);
  final startDate = DateTime(
    previousBillDate.year,
    previousBillDate.month,
    previousBillDate.day + 1,
  );

  return BillingCyclePeriod(startDate: startDate, endDate: endDate);
}

DateTime _billDateOnOrAfter(DateTime date, int billDayOfMonth) {
  final thisMonthBill = _billDateInMonth(date.year, date.month, billDayOfMonth);
  if (!date.isAfter(thisMonthBill)) {
    return thisMonthBill;
  }

  final nextMonth = DateTime(date.year, date.month + 1);
  return _billDateInMonth(nextMonth.year, nextMonth.month, billDayOfMonth);
}

DateTime _billDateBefore(DateTime billDate, int billDayOfMonth) {
  final previousMonth = DateTime(billDate.year, billDate.month - 1);
  return _billDateInMonth(
    previousMonth.year,
    previousMonth.month,
    billDayOfMonth,
  );
}

DateTime _billDateInMonth(int year, int month, int billDayOfMonth) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = billDayOfMonth.clamp(1, lastDay);
  return DateTime(year, month, day);
}
