const _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _weekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String formatTransactionSubtitle(DateTime date, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  final txDay = DateTime(date.year, date.month, date.day);
  final dayDiff = today.difference(txDay).inDays;
  final time = _formatTime(date);

  if (dayDiff == 0) {
    return 'Today · $time';
  }
  if (dayDiff == 1) {
    return 'Yesterday · $time';
  }
  if (dayDiff < 7) {
    return '${_weekdayLabels[date.weekday - 1]} · $time';
  }

  return '${date.day.toString().padLeft(2, '0')} '
      '${_monthLabels[date.month - 1]} ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
