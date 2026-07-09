import 'package:spendsense/features/sms_capture/parsers/parser_utils.dart';

List<String> filterSmsSince(
  List<String> messages, {
  required DateTime since,
}) {
  final sinceDay = DateTime(since.year, since.month, since.day);

  return messages.where((message) {
    final messageDate = parseSmsDate(message);
    if (messageDate == null) {
      return false;
    }
    final day = DateTime(messageDate.year, messageDate.month, messageDate.day);
    return !day.isBefore(sinceDay);
  }).toList();
}
