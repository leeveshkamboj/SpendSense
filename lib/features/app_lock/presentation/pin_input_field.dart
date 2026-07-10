import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric PIN entry with visual digit slots and auto-complete callback.
class PinInputField extends StatefulWidget {
  const PinInputField({
    required this.controller,
    this.length = 4,
    this.autofocus = false,
    this.onCompleted,
    this.label,
    this.helperText,
    super.key,
  });

  final TextEditingController controller;
  final int length;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;
  final String? label;
  final String? helperText;

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChanged);
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged() {
    final text = widget.controller.text;
    if (text.length > widget.length) {
      widget.controller.text = text.substring(0, widget.length);
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
      return;
    }

    setState(() {});
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = widget.controller.text.length;
    final focused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: List.generate(widget.length, (index) {
                  final isActive = focused && index == filled;
                  final isFilled = index < filled;
                  return Expanded(
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == widget.length - 1 ? 0 : 6,
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
              ),
              Opacity(
                opacity: 0.01,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                  maxLength: widget.length,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
