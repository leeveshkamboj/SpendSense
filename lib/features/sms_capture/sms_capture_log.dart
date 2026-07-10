import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

const smsCaptureLogName = 'SpendSense.SmsCapture';

void smsCaptureLog(String message) {
  debugPrint('[$smsCaptureLogName] $message');
  developer.log(message, name: smsCaptureLogName);
}

void smsCaptureLogError(
  String message, [
  Object? error,
  StackTrace? stackTrace,
]) {
  debugPrint('[$smsCaptureLogName] ERROR $message');
  developer.log(
    message,
    name: smsCaptureLogName,
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );
}

String smsPreview(String sms, {int maxLength = 100}) {
  final plain = sms.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (plain.length <= maxLength) {
    return plain;
  }
  return '${plain.substring(0, maxLength)}...';
}

bool looksBankRelatedSms(String sms) {
  final upper = sms.toUpperCase();
  return upper.contains('RS.') ||
      upper.contains('RS ') ||
      upper.contains('INR') ||
      upper.contains('DEBITED') ||
      upper.contains('CREDITED') ||
      upper.contains('SPENT') ||
      upper.contains('SBI') ||
      upper.contains('HDFC') ||
      upper.contains('ICICI') ||
      upper.contains('AXIS') ||
      upper.contains('KOTAK') ||
      upper.contains('CREDIT CARD') ||
      upper.contains('UPI');
}
