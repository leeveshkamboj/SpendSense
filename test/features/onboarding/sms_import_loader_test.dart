import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';

void main() {
  group('SMS import loader', () {
    test('defaults fresh import to the last twelve months', () {
      final since = smsImportWindowStart(now: DateTime(2026, 7, 10));

      expect(since, DateTime(2025, 7, 10));
    });

    test('billing history defaults to twelve months back', () {
      final since = billingHistoryStart(now: DateTime(2026, 7, 10));

      expect(since, DateTime(2025, 7, 10));
    });

    test('honors a custom import window length', () {
      final since = smsImportWindowStart(
        now: DateTime(2026, 7, 10),
        months: 3,
      );

      expect(since, DateTime(2026, 4, 10));
    });

    test('uses restore date when it is more recent than the window', () {
      final since = smsImportWindowStart(
        restoreSince: DateTime(2026, 6, 1),
        now: DateTime(2026, 7, 10),
      );

      expect(since, DateTime(2026, 6, 1));
    });

    test('imports all inbox messages since the import window', () async {
      final inbox = InMemorySmsInboxGateway([
        SmsInboxMessage(
          sender: 'VM-HDFCBK',
          body: 'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
          receivedAt: DateTime(2026, 7, 9),
        ),
        SmsInboxMessage(
          sender: 'VM-RANDOM',
          body: 'hello',
          receivedAt: DateTime(2026, 7, 9),
        ),
        SmsInboxMessage(
          sender: 'VM-HDFCBK',
          body: 'old message',
          receivedAt: DateTime(2025, 1, 1),
        ),
      ]);

      final messages = await loadSmsMessagesForImport(
        inbox: inbox,
        since: DateTime(2026, 4, 1),
      );

      expect(messages, hasLength(2));
      expect(messages.first, contains('ZOMATO'));
      expect(messages.last, 'hello');
    });
  });
}
