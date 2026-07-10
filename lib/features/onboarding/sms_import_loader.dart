import 'package:spendsense/features/onboarding/sms_import_log.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_capture_log.dart';
import 'package:spendsense/features/sms_capture/sms_parse_diagnostics.dart';

const smsImportWindowMonths = 2;
const billingHistoryMonths = 2;

DateTime smsImportWindowStart({DateTime? restoreSince, DateTime? now}) {
  final clock = now ?? DateTime.now();
  final windowStart = DateTime(
    clock.year,
    clock.month - smsImportWindowMonths,
    clock.day,
  );
  if (restoreSince == null) {
    return windowStart;
  }
  return restoreSince.isAfter(windowStart) ? restoreSince : windowStart;
}

DateTime billingHistoryStart({DateTime? now}) {
  final clock = now ?? DateTime.now();
  return DateTime(
    clock.year,
    clock.month - billingHistoryMonths,
    clock.day,
  );
}

Future<List<String>> loadSmsMessagesForImport({
  required SmsInboxGateway inbox,
  required DateTime since,
}) async {
  smsImportLog('Loading inbox messages since ${since.toIso8601String()}');

  final messages = await inbox.readInbox(since: since);
  final smsCount =
      messages.where((message) => message.channel == InboxMessageChannel.sms).length;
  final rcsCount = messages.length - smsCount;
  smsImportLog(
    'Read ${messages.length} inbox messages from device (sms=$smsCount rcs_mms=$rcsCount)',
  );

  final senderCounts = <String, int>{};
  for (final message in messages) {
    senderCounts.update(message.sender, (count) => count + 1, ifAbsent: () => 1);
  }
  final topSenders = senderCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (topSenders.isNotEmpty) {
    smsImportLog(
      'Top inbox senders: '
      '${topSenders.take(8).map((entry) => '${entry.key}(${entry.value})').join(', ')}',
    );
  }

  final bodies = messages.map((message) => message.body).toList(growable: false);
  smsImportLog('Prepared ${bodies.length} messages for import');

  final bankLike = bodies.where(looksBankRelatedSms).length;
  final sbiLike = bodies
      .where((body) => body.toUpperCase().contains('SBI'))
      .length;
  smsImportLog(
    'Inbox bank-like messages: $bankLike (SBI mentions: $sbiLike)',
  );

  return bodies;
}
