import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';

class SmsPermissionBanner extends ConsumerWidget {
  const SmsPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(smsPermissionStateProvider);

    return permission.when(
      data: (state) {
        if (state == SmsPermissionState.granted) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          content: const Text(
            'SMS permission is required for automatic capture. '
            'Manual entry remains available.',
          ),
          actions: [
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Settings'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(smsPermissionGatewayProvider).request();
                ref.invalidate(smsPermissionStateProvider);
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
