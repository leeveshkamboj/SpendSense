import 'package:permission_handler/permission_handler.dart';
import 'package:spendsense/features/bills/domain/bill_reminders.dart';

enum NotificationPermissionState {
  granted,
  denied,
}

abstract class NotificationPermissionGateway {
  Future<NotificationPermissionState> check();
  Future<NotificationPermissionState> request();
}

class PermissionHandlerNotificationGateway
    implements NotificationPermissionGateway {
  @override
  Future<NotificationPermissionState> check() async {
    final status = await Permission.notification.status;
    return status.isGranted
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
  }

  @override
  Future<NotificationPermissionState> request() async {
    final status = await Permission.notification.request();
    return status.isGranted
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
  }
}

class InMemoryNotificationPermissionGateway
    implements NotificationPermissionGateway {
  InMemoryNotificationPermissionGateway(this._state);

  NotificationPermissionState _state;

  @override
  Future<NotificationPermissionState> check() async => _state;

  @override
  Future<NotificationPermissionState> request() async {
    _state = NotificationPermissionState.granted;
    return _state;
  }

  void deny() {
    _state = NotificationPermissionState.denied;
  }
}

abstract class BillReminderScheduler {
  Future<void> cancelAll();
  Future<void> schedule(BillReminder reminder);
}

class InMemoryBillReminderScheduler implements BillReminderScheduler {
  final scheduled = <BillReminder>[];

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
  }

  @override
  Future<void> schedule(BillReminder reminder) async {
    scheduled.add(reminder);
  }
}
