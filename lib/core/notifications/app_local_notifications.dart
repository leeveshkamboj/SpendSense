import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_action_handler.dart';

class AppLocalNotifications {
  AppLocalNotifications._(this.plugin);

  final FlutterLocalNotificationsPlugin plugin;
  static AppLocalNotifications? _instance;

  static AppLocalNotifications get instance {
    final current = _instance;
    if (current == null) {
      throw StateError('AppLocalNotifications.initialize() must be called first');
    }
    return current;
  }

  static Future<AppLocalNotifications> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse:
          CaptureNotificationActionHandler.handleForegroundResponse,
      onDidReceiveBackgroundNotificationResponse:
          captureNotificationBackgroundResponse,
    );

    _instance = AppLocalNotifications._(plugin);
    return _instance!;
  }
}

@pragma('vm:entry-point')
void captureNotificationBackgroundResponse(NotificationResponse response) {
  CaptureNotificationActionHandler.handleBackgroundResponse(response);
}
