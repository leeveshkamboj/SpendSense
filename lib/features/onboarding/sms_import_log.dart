import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

const smsImportLogName = 'SpendSense.SmsImport';

void smsImportLog(String message) {
  debugPrint('[$smsImportLogName] $message');
  developer.log(message, name: smsImportLogName);
}

void smsImportLogError(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: smsImportLogName,
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );
}
