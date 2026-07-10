import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';

void main() {
  group('parseInboxMessages', () {
    test('maps platform channel payloads into inbox messages', () {
      final messages = parseInboxMessages([
        {
          'sender': 'VM-HDFCBK',
          'body': 'Spent Rs.100',
          'receivedAtMs': DateTime(2026, 7, 9).millisecondsSinceEpoch,
          'channel': 'sms',
        },
        {
          'sender': 'VM-SBICRD-S',
          'body': 'Rs.2,000.00 spent on your SBI Credit Card ending with 8401 at MAMTARANI on 25-05-26',
          'receivedAtMs': DateTime(2026, 5, 25).millisecondsSinceEpoch,
          'channel': 'rcs_mms',
        },
      ]);

      expect(messages, hasLength(2));
      expect(messages.first.sender, 'VM-HDFCBK');
      expect(messages.first.channel, InboxMessageChannel.sms);
      expect(messages.last.channel, InboxMessageChannel.rcsMms);
      expect(messages.last.body, contains('MAMTARANI'));
    });
  });
}
