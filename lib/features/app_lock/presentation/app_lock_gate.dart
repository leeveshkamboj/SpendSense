import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/app_lock/app_lock_providers.dart';
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
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
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
        return _LockScreen(
          pinController: _pinController,
          onUnlock: () => setState(() => _unlocked = true),
        );
      },
      loading: () => widget.child,
      error: (_, _) => widget.child,
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen({
    required this.pinController,
    required this.onUnlock,
  });

  final TextEditingController pinController;
  final VoidCallback onUnlock;

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeUnlock());
  }

  Future<void> _initializeUnlock() async {
    final repository = ref.read(appLockRepositoryProvider);
    final available = await repository.canUnlockWithBiometrics();
    if (!mounted) {
      return;
    }

    setState(() => _biometricAvailable = available);
    if (available) {
      await _tryBiometricUnlock();
    }
  }

  Future<void> _tryBiometricUnlock() async {
    final unlocked =
        await ref.read(appLockRepositoryProvider).unlockWithBiometrics();
    if (!mounted || !unlocked) {
      return;
    }

    widget.pinController.clear();
    widget.onUnlock();
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
              Text(
                'SpendSense is locked',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: widget.pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onSubmitted: (_) => _verify(context),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _verify(context),
                child: const Text('Unlock'),
              ),
              if (_biometricAvailable)
                TextButton.icon(
                  onPressed: _tryBiometricUnlock,
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

  Future<void> _verify(BuildContext context) async {
    final valid = await ref
        .read(appLockRepositoryProvider)
        .verifyPin(widget.pinController.text);
    if (!context.mounted) {
      return;
    }
    if (valid) {
      widget.pinController.clear();
      widget.onUnlock();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect PIN')),
    );
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
