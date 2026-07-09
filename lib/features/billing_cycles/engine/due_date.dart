/// Returns the date by which a billed cycle must be paid.
DateTime calculateDueDate({
  required DateTime billDate,
  required int dueDateOffsetDays,
}) {
  return DateTime(
    billDate.year,
    billDate.month,
    billDate.day + dueDateOffsetDays,
  );
}
