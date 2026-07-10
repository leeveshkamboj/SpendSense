import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/app_lock/app_lock_providers.dart';
import 'package:spendsense/features/app_lock/presentation/pin_input_field.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

/// Gates the app behind PIN/biometric unlock for the current process session.
///
/// Once unlocked, stays unlocked until the process is killed (app closed).
/// Does not re-lock on background/inactive — that fights the system biometric
/// sheet and made PIN entry unreachable.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _unlocked = false;

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

class _LockScreenState extends ConsumerState<_LockScreen> {
  final _pinController = TextEditingController();
  var _biometricAvailable = false;
  var _biometricPromptInFlight = false;
  var _errorText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeUnlock());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const AppLogo(size: 56),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _biometricAvailable
                          ? 'Enter PIN or use biometric'
                          : 'Enter your PIN to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    PinInputField(
                      controller: _pinController,
                      style: PinInputStyle.unlock,
                      onCompleted: (_) => _verify(),
                      onBiometric: _biometricAvailable
                          ? _promptBiometricIfAvailable
                          : null,
                    ),
                    if (_errorText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorText,
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _resetPin(context),
                      child: const Text('Forgot PIN?'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
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
