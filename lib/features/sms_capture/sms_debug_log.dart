import 'package:flutter/foundation.dart';

/// Temporary capture diagnostics. Grep logcat / console for `[DEBUG-sms]`.
void smsDebugLog(String message, [Object? error, StackTrace? stackTrace]) {
  final line = '[DEBUG-sms] $message';
  if (error != null) {
    debugPrint('$line error=$error');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
    return;
  }
  debugPrint(line);
}
