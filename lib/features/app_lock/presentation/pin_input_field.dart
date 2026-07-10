import 'package:flutter/material.dart';

enum PinInputStyle {
  /// Labeled boxes — used in settings / setup sheets.
  form,

  /// Circular dots + spacious keypad — used on the unlock screen.
  unlock,
}

/// Numeric PIN entry with visual digit slots and an on-screen keypad.
class PinInputField extends StatefulWidget {
  const PinInputField({
    required this.controller,
    this.length = 4,
    this.autofocus = false,
    this.onCompleted,
    this.onBiometric,
    this.label,
    this.helperText,
    this.showKeypad = true,
    this.style = PinInputStyle.form,
    super.key,
  });

  final TextEditingController controller;
  final int length;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;
  /// When set, shows a fingerprint key in the bottom-left of the keypad.
  final VoidCallback? onBiometric;
  final String? label;
  final String? helperText;
  final bool showKeypad;
  final PinInputStyle style;

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() {
    final text = widget.controller.text;
    if (text.length > widget.length) {
      widget.controller.text = text.substring(0, widget.length);
      return;
    }

    setState(() {});
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  void _appendDigit(String digit) {
    if (widget.controller.text.length >= widget.length) {
      return;
    }
    widget.controller.text = '${widget.controller.text}$digit';
  }

  void _removeDigit() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      return;
    }
    widget.controller.text = text.substring(0, text.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = widget.controller.text.length;
    final isUnlock = widget.style == PinInputStyle.unlock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
        ],
        if (isUnlock)
          _UnlockDots(length: widget.length, filled: filled)
        else
          _FormSlots(length: widget.length, filled: filled),
        if (widget.helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: isUnlock ? TextAlign.center : TextAlign.start,
          ),
        ],
        if (widget.showKeypad) ...[
          SizedBox(height: isUnlock ? 36 : 24),
          _PinKeypad(
            onDigit: _appendDigit,
            onBackspace: _removeDigit,
            onBiometric: widget.onBiometric,
            compact: !isUnlock,
          ),
        ],
      ],
    );
  }
}

class _UnlockDots extends StatelessWidget {
  const _UnlockDots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: isFilled
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FormSlots extends StatelessWidget {
  const _FormSlots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(length, (index) {
        final isActive = index == filled;
        final isFilled = index < filled;
        return Expanded(
          child: Container(
            height: 56,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 6,
              right: index == length - 1 ? 0 : 6,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isActive ? 2 : 1,
              ),
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              isFilled ? '•' : '',
              style: theme.textTheme.headlineSmall,
            ),
          ),
        );
      }),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.compact = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 12.0 : 16.0;
    final keyHeight = compact ? 56.0 : 64.0;

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(
                    child: _PinKey(
                      digit: row[i],
                      onPressed: onDigit,
                      height: keyHeight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: onBiometric == null
                  ? const SizedBox.shrink()
                  : _PinKey(
                      icon: Icons.fingerprint,
                      onPressed: (_) => onBiometric!(),
                      height: keyHeight,
                      tonal: true,
                    ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _PinKey(
                digit: '0',
                onPressed: onDigit,
                height: keyHeight,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _PinKey(
                icon: Icons.backspace_outlined,
                onPressed: (_) => onBackspace(),
                height: keyHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    this.digit,
    this.icon,
    required this.onPressed,
    this.height = 56,
    this.tonal = false,
  }) : assert(digit != null || icon != null);

  final String? digit;
  final IconData? icon;
  final ValueChanged<String> onPressed;
  final double height;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = tonal
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = tonal
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      label: icon == Icons.fingerprint ? 'Unlock with biometric' : null,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(height / 2),
        child: InkWell(
          onTap: () {
            if (digit != null) {
              onPressed(digit!);
            } else {
              onPressed('');
            }
          },
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: foreground, size: tonal ? 28 : 24)
                  : Text(
                      digit!,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
