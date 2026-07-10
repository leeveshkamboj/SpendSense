import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/app/router.dart';
import 'package:spendsense/core/notifications/app_local_notifications.dart';
import 'package:spendsense/features/home_widgets/domain/home_widget_launch.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_action_handler.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_navigation.dart';

class CaptureNotificationLaunchListener extends ConsumerStatefulWidget {
  const CaptureNotificationLaunchListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<CaptureNotificationLaunchListener> createState() =>
      _CaptureNotificationLaunchListenerState();
}

class _CaptureNotificationLaunchListenerState
    extends ConsumerState<CaptureNotificationLaunchListener> {
  @override
  void initState() {
    super.initState();
    CaptureNotificationNavigation.onForegroundTap = _navigateForResponse;
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleColdStart());
  }

  @override
  void dispose() {
    if (identical(
      CaptureNotificationNavigation.onForegroundTap,
      _navigateForResponse,
    )) {
      CaptureNotificationNavigation.onForegroundTap = null;
    }
    super.dispose();
  }

  Future<void> _handleColdStart() async {
    final details = await AppLocalNotifications.instance.plugin
        .getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp != true || response == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _navigateForResponse(response);
  }

  Future<void> _navigateForResponse(NotificationResponse response) async {
    final payload = CaptureNotificationActionHandler.decodePayload(
      response.payload,
    );
    if (payload == null) {
      return;
    }

    final route = HomeWidgetLaunch.routeFor(
      Uri.parse(CaptureNotificationActionHandler.launchUriFor(payload)),
    );
    if (route == null || !mounted) {
      return;
    }

    ref.read(routerProvider).go(route);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
