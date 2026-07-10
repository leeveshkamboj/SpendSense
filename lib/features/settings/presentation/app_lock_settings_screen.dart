import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/app_lock/app_lock_providers.dart';
import 'package:spendsense/features/app_lock/presentation/app_lock_pin_setup_sheet.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

class AppLockSettingsScreen extends ConsumerStatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  ConsumerState<AppLockSettingsScreen> createState() =>
      _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends ConsumerState<AppLockSettingsScreen> {
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
                    onChanged: (value) => _setBiometricEnabled(context, value),
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
    final repository = ref.read(appLockRepositoryProvider);
    final biometricAvailable =
        await ref.read(appLockGatewayProvider).canCheckBiometrics();

    if (!context.mounted) {
      return;
    }

    final result = await showAppLockPinSetupSheet(
      context: context,
      title: 'Set app lock PIN',
      offerBiometric: true,
      biometricAvailable: biometricAvailable,
    );

    if (result == null) {
      return;
    }

    await repository.enableWithPin(result.pin);
    if (result.enableBiometric) {
      final verified =
          await ref.read(appLockGatewayProvider).authenticateWithBiometrics();
      await repository.setBiometricEnabled(verified);
    } else {
      await repository.setBiometricEnabled(false);
    }
    ref.invalidate(appLockEnabledProvider);
  }

  Future<void> _setBiometricEnabled(BuildContext context, bool value) async {
    final repository = ref.read(appLockRepositoryProvider);

    if (value) {
      final available =
          await ref.read(appLockGatewayProvider).canCheckBiometrics();
      if (!available) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric unlock is not available on this device'),
          ),
        );
        return;
      }

      final verified =
          await ref.read(appLockGatewayProvider).authenticateWithBiometrics();
      if (!verified) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric verification failed')),
        );
        return;
      }
    }

    await repository.setBiometricEnabled(value);
    if (context.mounted) {
      setState(() {});
    }
  }

  Future<void> _resetPin(BuildContext context) async {
    final result = await showAppLockPinSetupSheet(
      context: context,
      title: 'Set new PIN',
      confirmLabel: 'Update PIN',
      offerBiometric: false,
      biometricAvailable: false,
    );

    if (result == null) {
      return;
    }

    final reset = await ref
        .read(appLockRepositoryProvider)
        .resetPinWithDeviceCredential(result.pin);
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
