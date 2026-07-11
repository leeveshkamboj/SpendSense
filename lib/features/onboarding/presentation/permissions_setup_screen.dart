import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';

class PermissionsSetupScreen extends ConsumerStatefulWidget {
  const PermissionsSetupScreen({
    required this.onComplete,
    super.key,
  });

  final VoidCallback onComplete;

  @override
  ConsumerState<PermissionsSetupScreen> createState() =>
      _PermissionsSetupScreenState();
}

class _PermissionsSetupScreenState extends ConsumerState<PermissionsSetupScreen> {
  SmsPermissionState? _sms;
  NotificationPermissionState? _notifications;
  LocationPermissionState? _location;
  bool _loading = true;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final sms = await ref.read(smsPermissionGatewayProvider).check();
    final notifications =
        await ref.read(notificationPermissionGatewayProvider).check();
    final location = await ref.read(locationPermissionGatewayProvider).check();

    if (!mounted) return;
    setState(() {
      _sms = sms;
      _notifications = notifications;
      _location = location;
      _loading = false;
    });
  }

  Future<void> _markLocationExplained() {
    return ref
        .read(appPreferencesRepositoryProvider)
        .markLocationPermissionExplained();
  }

  Future<void> _requestSms() async {
    setState(() => _requesting = true);
    try {
      await ref.read(smsPermissionGatewayProvider).request();
      ref.invalidate(smsPermissionStateProvider);
      await _refresh();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _requestNotifications() async {
    setState(() => _requesting = true);
    try {
      await ref.read(notificationPermissionGatewayProvider).request();
      ref.invalidate(notificationPermissionStateProvider);
      await _refresh();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _requestLocation() async {
    setState(() => _requesting = true);
    try {
      await _markLocationExplained();
      await ref.read(locationPermissionGatewayProvider).request();
      await _refresh();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _allowAll() async {
    setState(() => _requesting = true);
    try {
      await ref.read(smsPermissionGatewayProvider).request();
      await ref.read(notificationPermissionGatewayProvider).request();
      await _markLocationExplained();
      await ref.read(locationPermissionGatewayProvider).request();
      ref.invalidate(smsPermissionStateProvider);
      ref.invalidate(notificationPermissionStateProvider);
      await _refresh();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _skip() async {
    await _markLocationExplained();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'SpendSense works best with a few permissions. '
                  'You can allow them now or skip and turn them on later in Settings.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _PermissionTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS',
                  description:
                      'Read bank SMS (and MMS/RCS when Google Messages stores them in the system inbox).',
                  granted: _sms == SmsPermissionState.granted,
                  onAllow: _requesting ? null : _requestSms,
                ),
                _PermissionTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  description:
                      'Send bill reminders and spending alerts.',
                  granted:
                      _notifications == NotificationPermissionState.granted,
                  onAllow: _requesting ? null : _requestNotifications,
                ),
                _PermissionTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  description:
                      'Tag expenses with where you were when a transaction happened.',
                  granted: _location == LocationPermissionState.granted,
                  onAllow: _requesting ? null : _requestLocation,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _requesting ? null : _allowAll,
                  child: const Text('Allow all'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: _requesting ? null : _skip,
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _requesting ? null : _skip,
                  child: const Text('Skip for now'),
                ),
              ],
            ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onAllow,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final VoidCallback? onAllow;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        granted ? Icons.check_circle : Icons.info_outline,
                        size: 18,
                        color: granted
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(granted ? 'Allowed' : 'Not allowed'),
                      const Spacer(),
                      if (!granted)
                        FilledButton.tonal(
                          onPressed: onAllow,
                          child: const Text('Allow'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
