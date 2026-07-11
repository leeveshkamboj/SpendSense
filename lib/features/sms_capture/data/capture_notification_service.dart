import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/core/notifications/app_local_notifications.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_action_handler.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';

class CaptureNotificationService {
  CaptureNotificationService(this._plugin);

  static const channelId = 'transaction_capture';
  static const channelName = 'Transaction Capture';
  static const manualAddChannelId = 'transaction_capture_manual';
  static const _manualAddThrottle = Duration(hours: 6);

  final FlutterLocalNotificationsPlugin _plugin;
  DateTime? _lastManualAddShownAt;

  static Future<CaptureNotificationService> create() async {
    final notifications = await AppLocalNotifications.initialize();
    final service = CaptureNotificationService(notifications.plugin);
    await service._ensureChannels();
    return service;
  }

  Future<void> _ensureChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Alerts when SpendSense captures a transaction from SMS',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        manualAddChannelId,
        'Manual Transaction Prompts',
        description: 'Prompts when a bank SMS could not be parsed automatically',
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> showCapture(CaptureNotificationEvent event) async {
    final payload = CaptureNotificationActionHandler.encodePayload(event);
    final actions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        CaptureNotificationActionHandler.reviewActionId,
        'Review',
        showsUserInterface: true,
      ),
      if (!event.isBankAccount)
        const AndroidNotificationAction(
          CaptureNotificationActionHandler.recoverableActionId,
          'Recoverable',
          showsUserInterface: true,
        ),
    ];

    await _plugin.show(
      event.transactionId,
      'Captured ${formatPaise(event.amountPaise)}',
      '${event.merchant} · ${event.cardNickname}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription:
              'Alerts when SpendSense captures a transaction from SMS',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.status,
          actions: actions,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> showManualAddSuggestion() async {
    final now = DateTime.now();
    final lastShown = _lastManualAddShownAt;
    if (lastShown != null && now.difference(lastShown) < _manualAddThrottle) {
      return;
    }
    _lastManualAddShownAt = now;

    await _plugin.show(
      manualAddNotificationId,
      'Add transaction manually',
      'SpendSense could not parse a recent bank SMS.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          manualAddChannelId,
          'Manual Transaction Prompts',
          channelDescription:
              'Prompts when a bank SMS could not be parsed automatically',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  static const manualAddNotificationId = 900001;
}
