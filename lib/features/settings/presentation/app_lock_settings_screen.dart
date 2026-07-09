import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/app_lock/app_lock_providers.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

class AppLockSettingsScreen extends ConsumerStatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  ConsumerState<AppLockSettingsScreen> createState() =>
      _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends ConsumerState<AppLockSettingsScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(appLockEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('App lock')),
      body: enabled.when(
        data: (isEnabled) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Enable app lock'),
              subtitle: const Text('Require PIN or biometric to open SpendSense'),
              value: isEnabled,
              onChanged: (value) async {
                if (value) {
                  await _enableLock(context);
                } else {
                  await ref.read(appLockRepositoryProvider).disable();
                  ref.invalidate(appLockEnabledProvider);
                }
              },
            ),
            if (isEnabled) ...[
              FutureBuilder<bool>(
                future: ref.read(appLockRepositoryProvider).isBiometricEnabled(),
                builder: (context, snapshot) {
                  return SwitchListTile(
                    title: const Text('Use biometric'),
                    subtitle: const Text('Unlock with fingerprint or face'),
                    value: snapshot.data ?? false,
                    onChanged: (value) async {
                      await ref
                          .read(appLockRepositoryProvider)
                          .setBiometricEnabled(value);
                      setState(() {});
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Reset PIN'),
                subtitle: const Text('Use device credential to set a new PIN'),
                onTap: () => _resetPin(context),
              ),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _enableLock(BuildContext context) async {
    _pinController.clear();
    _confirmController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set app lock PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        _pinController.text.length < 4 ||
        _pinController.text != _confirmController.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN must match and be at least 4 digits')),
        );
      }
      return;
    }

    await ref.read(appLockRepositoryProvider).enableWithPin(_pinController.text);
    ref.invalidate(appLockEnabledProvider);
  }

  Future<void> _resetPin(BuildContext context) async {
    _pinController.clear();
    _confirmController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set new PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'New PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        _pinController.text.length < 4 ||
        _pinController.text != _confirmController.text) {
      return;
    }

    final reset = await ref
        .read(appLockRepositoryProvider)
        .resetPinWithDeviceCredential(_pinController.text);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reset ? 'PIN updated' : 'Device verification failed'),
      ),
    );
  }
}
