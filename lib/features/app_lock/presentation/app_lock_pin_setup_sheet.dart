import 'package:flutter/material.dart';
import 'package:spendsense/features/app_lock/presentation/pin_input_field.dart';

class AppLockPinSetupResult {
  const AppLockPinSetupResult({
    required this.pin,
    required this.enableBiometric,
  });

  final String pin;
  final bool enableBiometric;
}

Future<AppLockPinSetupResult?> showAppLockPinSetupSheet({
  required BuildContext context,
  required String title,
  String confirmLabel = 'Save PIN',
  bool offerBiometric = false,
  bool biometricAvailable = false,
}) {
  return showModalBottomSheet<AppLockPinSetupResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AppLockPinSetupSheet(
      title: title,
      confirmLabel: confirmLabel,
      offerBiometric: offerBiometric,
      biometricAvailable: biometricAvailable,
    ),
  );
}

class _AppLockPinSetupSheet extends StatefulWidget {
  const _AppLockPinSetupSheet({
    required this.title,
    required this.confirmLabel,
    required this.offerBiometric,
    required this.biometricAvailable,
  });

  final String title;
  final String confirmLabel;
  final bool offerBiometric;
  final bool biometricAvailable;

  @override
  State<_AppLockPinSetupSheet> createState() => _AppLockPinSetupSheetState();
}

class _AppLockPinSetupSheetState extends State<_AppLockPinSetupSheet> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  var _step = _SetupStep.enterPin;
  var _enableBiometric = true;
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goToConfirm() {
    if (_pinController.text.length < 4) {
      setState(() => _errorText = 'PIN must be at least 4 digits');
      return;
    }
    setState(() {
      _errorText = null;
      _step = _SetupStep.confirmPin;
      _confirmController.clear();
    });
  }

  void _submit() {
    if (_confirmController.text != _pinController.text) {
      setState(() => _errorText = 'PINs do not match');
      return;
    }

    Navigator.of(context).pop(
      AppLockPinSetupResult(
        pin: _pinController.text,
        enableBiometric: widget.offerBiometric &&
            widget.biometricAvailable &&
            _enableBiometric,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _step == _SetupStep.enterPin
                ? 'Choose a 4-digit PIN'
                : 'Enter the same PIN again',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_step == _SetupStep.enterPin)
            PinInputField(
              key: const ValueKey('enter-pin'),
              controller: _pinController,
              label: 'PIN',
              helperText: 'Tap the numbers below',
              onCompleted: (_) => _goToConfirm(),
            )
          else
            PinInputField(
              key: const ValueKey('confirm-pin'),
              controller: _confirmController,
              label: 'Confirm PIN',
              helperText: 'Tap the numbers below',
              onCompleted: (_) => _submit(),
            ),
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          if (_step == _SetupStep.confirmPin &&
              widget.offerBiometric &&
              widget.biometricAvailable) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Unlock with biometric'),
              subtitle: const Text('Fingerprint or face when opening the app'),
              value: _enableBiometric,
              onChanged: (value) => setState(() => _enableBiometric = value),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _step == _SetupStep.enterPin ? _goToConfirm : _submit,
            child: Text(
              _step == _SetupStep.enterPin ? 'Continue' : widget.confirmLabel,
            ),
          ),
          if (_step == _SetupStep.confirmPin)
            TextButton(
              onPressed: () => setState(() {
                _step = _SetupStep.enterPin;
                _errorText = null;
                _confirmController.clear();
              }),
              child: const Text('Back'),
            ),
        ],
        ),
      ),
    );
  }
}

enum _SetupStep { enterPin, confirmPin }
