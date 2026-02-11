import 'package:flutter/material.dart';
import '../../tokens/index.dart';

/// A button that requires a second tap to confirm (slide or hold pattern).
class ConfirmationButton extends StatefulWidget {
  const ConfirmationButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.confirmLabel = 'Confirm',
    this.isLoading = false,
    this.isDestructive = false,
  });

  final String label;
  final String confirmLabel;
  final VoidCallback onConfirmed;
  final bool isLoading;
  final bool isDestructive;

  @override
  State<ConfirmationButton> createState() => _ConfirmationButtonState();
}

class _ConfirmationButtonState extends State<ConfirmationButton> {
  bool _isConfirming = false;

  void _handleTap() {
    if (widget.isLoading) return;
    if (_isConfirming) {
      widget.onConfirmed();
      setState(() => _isConfirming = false);
    } else {
      setState(() => _isConfirming = true);
      // Auto-reset after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isConfirming = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = _isConfirming
        ? (widget.isDestructive ? colors.error : colors.primary)
        : colors.surface;
    final textColor = _isConfirming ? Colors.white : colors.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(textColor),
                  ),
                )
              : Text(
                  _isConfirming ? widget.confirmLabel : widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
