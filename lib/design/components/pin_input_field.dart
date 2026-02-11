/// Reusable PIN input field with dots indicator.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscured;
  final bool autofocus;
  final String? errorText;

  const PinInputField({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
    this.obscured = true,
    this.autofocus = true,
    this.errorText,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted(value);
    }
  }

  void clear() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Semantics(
            label: 'PIN input, ${_controller.text.length} of ${widget.length} digits entered',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (index) {
                final isFilled = index < _controller.text.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? (hasError ? theme.colorScheme.error : theme.colorScheme.primary)
                        : Colors.transparent,
                    border: Border.all(
                      color: hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // Hidden text field for keyboard input
        SizedBox(
          width: 0,
          height: 0,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.number,
            maxLength: widget.length,
            obscureText: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: _onChanged,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 16),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
