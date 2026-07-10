import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendsense/core/notifications/app_local_notifications.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/bills/domain/bill_reminders.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsBillReminderScheduler implements BillReminderScheduler {
  LocalNotificationsBillReminderScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static bool _timezoneInitialized = false;

  static Future<LocalNotificationsBillReminderScheduler> create() async {
    final notifications = await AppLocalNotifications.initialize();
    if (!_timezoneInitialized) {
      tz_data.initializeTimeZones();
      _timezoneInitialized = true;
    }

    return LocalNotificationsBillReminderScheduler(notifications.plugin);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> schedule(BillReminder reminder) async {
    final scheduledDate = tz.TZDateTime.from(reminder.scheduledAt, tz.local);
    final title = switch (reminder.kind) {
      BillReminderKind.threeDaysBefore => 'Bill due in 3 days',
      BillReminderKind.oneDayBefore => 'Bill due tomorrow',
      BillReminderKind.onDueDate => 'Bill due today',
    };

    await _plugin.zonedSchedule(
      reminder.cycleId * 10 + reminder.kind.index,
      title,
      '${reminder.cardNickname}: ${formatPaise(reminder.netOutstandingPaise)}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bill_reminders',
          'Bill Reminders',
          channelDescription: 'Reminders for upcoming credit card bills',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
