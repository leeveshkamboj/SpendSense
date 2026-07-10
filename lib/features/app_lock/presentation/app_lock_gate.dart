import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/app_lock/app_lock_providers.dart';
import 'package:spendsense/features/app_lock/presentation/pin_input_field.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _unlocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(appLockEnabledProvider);

    return enabled.when(
      data: (isEnabled) {
        if (!isEnabled || _unlocked) {
          return widget.child;
        }
        return _LockScreen(onUnlock: () => setState(() => _unlocked = true));
      },
      loading: () => widget.child,
      error: (_, _) => widget.child,
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen>
    with WidgetsBindingObserver {
  final _pinController = TextEditingController();
  var _biometricAvailable = false;
  var _biometricPromptInFlight = false;
  var _errorText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeUnlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _promptBiometricIfAvailable();
    }
  }

  Future<void> _initializeUnlock() async {
    final repository = ref.read(appLockRepositoryProvider);
    final available = await repository.canUnlockWithBiometrics();
    if (!mounted) {
      return;
    }

    setState(() => _biometricAvailable = available);
    await _promptBiometricIfAvailable();
  }

  Future<void> _promptBiometricIfAvailable() async {
    if (!_biometricAvailable || _biometricPromptInFlight) {
      return;
    }

    _biometricPromptInFlight = true;
    try {
      final unlocked =
          await ref.read(appLockRepositoryProvider).unlockWithBiometrics();
      if (!mounted || !unlocked) {
        return;
      }

      _pinController.clear();
      widget.onUnlock();
    } finally {
      _biometricPromptInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const AppLogo(size: 80),
              const SizedBox(height: 20),
              Icon(
                Icons.lock_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'SpendSense is locked',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _biometricAvailable
                    ? 'Use biometric or enter your PIN'
                    : 'Enter your PIN to continue',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PinInputField(
                controller: _pinController,
                autofocus: !_biometricAvailable,
                label: 'PIN',
                onCompleted: (_) => _verify(),
              ),
              if (_errorText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              if (_biometricAvailable)
                FilledButton.tonalIcon(
                  onPressed: _promptBiometricIfAvailable,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with biometric'),
                ),
              TextButton(
                onPressed: () => _resetPin(context),
                child: const Text('Forgot PIN? Use device credential'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final valid = await ref
        .read(appLockRepositoryProvider)
        .verifyPin(_pinController.text);
    if (!mounted) {
      return;
    }
    if (valid) {
      setState(() => _errorText = '');
      _pinController.clear();
      widget.onUnlock();
      return;
    }

    setState(() {
      _errorText = 'Incorrect PIN';
      _pinController.clear();
    });
  }

  Future<void> _resetPin(BuildContext context) async {
    final reset = await ref
        .read(appLockRepositoryProvider)
        .resetPinWithDeviceCredential('0000');
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reset
              ? 'PIN reset via device credential. Set a new PIN in Settings.'
              : 'Device verification failed',
        ),
      ),
    );
    if (reset) {
      await ref.read(appLockRepositoryProvider).disable();
      ref.invalidate(appLockEnabledProvider);
      widget.onUnlock();
    }
  }
}
