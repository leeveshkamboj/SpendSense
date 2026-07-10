import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_navigation.dart';
import 'package:spendsense/features/sms_capture/background/sms_capture_runtime.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';

class CaptureNotificationActionHandler {
  static const reviewActionId = 'capture_review';
  static const recoverableActionId = 'capture_recoverable';

  static Future<void> handleForegroundResponse(
    NotificationResponse response,
  ) async {
    await _handle(response);
    await CaptureNotificationNavigation.onForegroundTap?.call(response);
  }

  static Future<void> handleBackgroundResponse(
    NotificationResponse response,
  ) async {
    await _handle(response);
  }

  static Future<void> _handle(NotificationResponse response) async {
    final payload = _decodePayload(response.payload);
    if (payload == null) {
      return;
    }

    final runtime = await SmsCaptureRuntime.open();
    try {
      await _applyAction(
        runtime: runtime,
        actionId: response.actionId,
        payload: payload,
      );
    } finally {
      await runtime.close();
    }
  }

  static Future<void> _applyAction({
    required SmsCaptureRuntime runtime,
    required String? actionId,
    required CaptureNotificationPayload payload,
  }) async {
    switch (actionId) {
      case reviewActionId:
        await runtime.markReviewed(
          transactionId: payload.transactionId,
          isBankAccount: payload.isBankAccount,
        );
      case recoverableActionId:
        break;
      case null:
      case '':
        break;
      default:
        break;
    }
  }

  static CaptureNotificationPayload? decodePayload(String? raw) =>
      _decodePayload(raw);

  static CaptureNotificationPayload? _decodePayload(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CaptureNotificationPayload(
        transactionId: map['transactionId'] as int,
        amountPaise: map['amountPaise'] as int,
        merchant: map['merchant'] as String,
        cardNickname: map['cardNickname'] as String,
        isBankAccount: map['isBankAccount'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  static String encodePayload(CaptureNotificationEvent event) {
    return jsonEncode({
      'transactionId': event.transactionId,
      'amountPaise': event.amountPaise,
      'merchant': event.merchant,
      'cardNickname': event.cardNickname,
      'isBankAccount': event.isBankAccount,
    });
  }

  static String launchUriFor(CaptureNotificationPayload payload) {
    return 'spendsense://widget/transaction/${payload.transactionId}';
  }
}

class CaptureNotificationPayload {
  const CaptureNotificationPayload({
    required this.transactionId,
    required this.amountPaise,
    required this.merchant,
    required this.cardNickname,
    required this.isBankAccount,
  });

  final int transactionId;
  final int amountPaise;
  final String merchant;
  final String cardNickname;
  final bool isBankAccount;
}
