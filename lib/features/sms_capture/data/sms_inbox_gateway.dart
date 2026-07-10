import 'package:flutter/services.dart';
import 'package:spendsense/features/onboarding/sms_import_log.dart';

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
    smsImportLog(
      'Querying Android inbox since ${since.toIso8601String()} '
      '(${since.millisecondsSinceEpoch} ms)',
    );

    try {
      final response = await _channel.invokeMethod<List<Object?>>(
        'readInboxSince',
        {'sinceMs': since.millisecondsSinceEpoch},
      );

      if (response == null) {
        smsImportLog('Android inbox query returned null');
        return const [];
      }

      final messages = parseInboxMessages(response);
      final smsCount =
          messages.where((message) => message.channel == InboxMessageChannel.sms).length;
      final rcsCount = messages.length - smsCount;
      smsImportLog(
        'Android inbox query returned ${messages.length} messages '
        '(sms=$smsCount rcs_mms=$rcsCount)',
      );
      return messages;
    } on PlatformException catch (error, stackTrace) {
      smsImportLogError(
        'Android inbox query failed: ${error.code} ${error.message}',
        error,
        stackTrace,
      );
      rethrow;
    }
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
            map['receivedAtMs'] as int,
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
