import 'package:flutter/services.dart';

enum InboxMessageChannel { sms, rcsMms }

class SmsInboxMessage {
  const SmsInboxMessage({
    required this.sender,
    required this.body,
    required this.receivedAt,
    this.channel = InboxMessageChannel.sms,
  });

  final String sender;
  final String body;
  final DateTime receivedAt;
  final InboxMessageChannel channel;
}

abstract class SmsInboxGateway {
  Future<List<SmsInboxMessage>> readInbox({required DateTime since});
}

class PlatformSmsInboxGateway implements SmsInboxGateway {
  PlatformSmsInboxGateway([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.spendsense.spendsense/sms_inbox';

  final MethodChannel _channel;

  @override
  Future<List<SmsInboxMessage>> readInbox({required DateTime since}) async {
    final response = await _channel.invokeMethod<List<Object?>>(
      'readInboxSince',
      {'sinceMs': since.millisecondsSinceEpoch},
    );

    if (response == null) {
      return const [];
    }

    return parseInboxMessages(response);
  }
}

List<SmsInboxMessage> parseInboxMessages(List<Object?> response) {
  return response
      .map((item) {
        final map = Map<Object?, Object?>.from(item! as Map);
        return SmsInboxMessage(
          sender: map['sender'] as String,
          body: map['body'] as String,
          receivedAt: DateTime.fromMillisecondsSinceEpoch(
            (map['receivedAtMs'] as num).toInt(),
          ),
          channel: _parseInboxChannel(map['channel'] as String?),
        );
      })
      .toList(growable: false);
}

InboxMessageChannel _parseInboxChannel(String? value) {
  return switch (value) {
    'rcs_mms' => InboxMessageChannel.rcsMms,
    _ => InboxMessageChannel.sms,
  };
}

class InMemorySmsInboxGateway implements SmsInboxGateway {
  InMemorySmsInboxGateway(this._messages);

  final List<SmsInboxMessage> _messages;

  @override
  Future<List<SmsInboxMessage>> readInbox({required DateTime since}) async {
    return _messages
        .where((message) => !message.receivedAt.isBefore(since))
        .toList(growable: false);
  }
}
