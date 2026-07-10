import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';

const defaultSmsImportWindowMonths = 12;

DateTime smsImportWindowStart({
  DateTime? restoreSince,
  DateTime? now,
  int months = defaultSmsImportWindowMonths,
}) {
  final clock = now ?? DateTime.now();
  final windowStart = DateTime(
    clock.year,
    clock.month - months,
    clock.day,
  );
  if (restoreSince == null) {
    return windowStart;
  }
  return restoreSince.isAfter(windowStart) ? restoreSince : windowStart;
}

DateTime billingHistoryStart({
  DateTime? now,
  int months = defaultSmsImportWindowMonths,
}) {
  final clock = now ?? DateTime.now();
  return DateTime(
    clock.year,
    clock.month - months,
    clock.day,
  );
}

Future<List<String>> loadSmsMessagesForImport({
  required SmsInboxGateway inbox,
  required DateTime since,
}) async {
  final messages = await inbox.readInbox(since: since);
  return messages.map((message) => message.body).toList(growable: false);
}
