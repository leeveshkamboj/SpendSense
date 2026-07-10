import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_action_handler.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';

void main() {
  test('encodes and decodes capture notification payload', () {
    const event = CaptureNotificationEvent(
      transactionId: 42,
      amountPaise: 41167,
      merchant: 'ZOMATO LTD',
      cardNickname: 'HDFC ••5534',
    );

    final encoded = CaptureNotificationActionHandler.encodePayload(event);
    final decoded = CaptureNotificationActionHandler.decodePayload(encoded);

    expect(decoded?.transactionId, 42);
    expect(decoded?.amountPaise, 41167);
    expect(decoded?.merchant, 'ZOMATO LTD');
    expect(decoded?.isBankAccount, false);
  });

  test('builds deep link for captured transaction', () {
    const payload = CaptureNotificationPayload(
      transactionId: 7,
      amountPaise: 100,
      merchant: 'Test',
      cardNickname: 'HDFC ••5534',
      isBankAccount: false,
    );

    expect(
      CaptureNotificationActionHandler.launchUriFor(payload),
      'spendsense://widget/transaction/7',
    );
  });
}
