import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';

final notificationPermissionGatewayProvider =
    Provider<NotificationPermissionGateway>((ref) {
  return PermissionHandlerNotificationGateway();
});

final notificationPermissionStateProvider =
    FutureProvider<NotificationPermissionState>((ref) {
  return ref.watch(notificationPermissionGatewayProvider).check();
});

class NotificationPermissionBanner extends ConsumerWidget {
  const NotificationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(notificationPermissionStateProvider);

    return permission.when(
      data: (state) {
        if (state == NotificationPermissionState.granted) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          content: const Text(
            'Bill reminders require notification permission. '
            'Reminders are disabled until you allow access.',
          ),
          actions: [
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Settings'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(notificationPermissionGatewayProvider).request();
                ref.invalidate(notificationPermissionStateProvider);
              },
              child: const Text('Allow'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
