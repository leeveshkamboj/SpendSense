import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef CaptureNotificationTapHandler = Future<void> Function(
  NotificationResponse response,
);

class CaptureNotificationNavigation {
  static CaptureNotificationTapHandler? onForegroundTap;
}
