import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';

/// Result of PIN confirmation
enum PinConfirmationResult {
  success,
  cancelled,
  failed,
}

/// A bottom sheet for PIN confirmation on sensitive operations
class PinConfirmationSheet extends StatefulWidget {
  const PinConfirmationSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.amount,
    this.recipient,
    required this.onConfirm,
    this.pinLength = 4,
    this.maxAttempts = 3,
  });

  final String title;
  final String? subtitle;
  final double? amount;
  final String? recipient;
  final Future<bool> Function(String pin) onConfirm;
  final int pinLength;
  final int maxAttempts;

  /// Show the PIN confirmation sheet and return the result
  static Future<PinConfirmationResult> show({
    required BuildContext context,
    required String title,
    String? subtitle,
    double? amount,
    String? recipient,
    required Future<bool> Function(String pin) onConfirm,
  }) async {
    final result = await showModalBottomSheet<PinConfirmationResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PinConfirmationSheet(
        title: title,
        subtitle: subtitle,
        amount: amount,
        recipient: recipient,
        onConfirm: onConfirm,
      ),
    );

    return result ?? PinConfirmationResult.cancelled;
  }

  @override
  State<PinConfirmationSheet> createState() => _PinConfirmationSheetState();
}

class _PinConfirmationSheetState extends State<PinConfirmationSheet> {
  String _pin = '';
  bool _isLoading = false;
  String? _error;
  int _attempts = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Lock icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: colors.gold,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              AppText(
                widget.title,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),

              // Subtitle
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  widget.subtitle!,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],

              // Transaction details
              if (widget.amount != null || widget.recipient != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      if (widget.amount != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'Amount',
                              variant: AppTextVariant.bodyMedium,
                              color: colors.textSecondary,
                            ),
                            AppText(
                              '\$${widget.amount!.toStringAsFixed(2)}',
                              variant: AppTextVariant.titleMedium,
                              color: colors.textPrimary,
                            ),
                          ],
                        ),
                      if (widget.amount != null && widget.recipient != null)
                        const SizedBox(height: AppSpacing.md),
                      if (widget.recipient != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'To',
                              variant: AppTextVariant.bodyMedium,
                              color: colors.textSecondary,
                            ),
                            Flexible(
                              child: AppText(
                                widget.recipient!,
                                variant: AppTextVariant.bodyMedium,
                                color: colors.textPrimary,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.pinLength,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: _PinDot(filled: index < _pin.length, colors: colors),
                  ),
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(
                  _error!,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.errorBase,
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Number pad
              _buildNumberPad(colors),

              const SizedBox(height: AppSpacing.lg),

              // Cancel button
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.pop(context, PinConfirmationResult.cancelled);
                },
                child: AppText(
                  'Cancel',
                  variant: AppTextVariant.labelLarge,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(ThemeColors colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NumberButton(number: '1', onPressed: () => _onNumberPressed('1'), colors: colors),
            _NumberButton(number: '2', onPressed: () => _onNumberPressed('2'), colors: colors),
            _NumberButton(number: '3', onPressed: () => _onNumberPressed('3'), colors: colors),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NumberButton(number: '4', onPressed: () => _onNumberPressed('4'), colors: colors),
            _NumberButton(number: '5', onPressed: () => _onNumberPressed('5'), colors: colors),
            _NumberButton(number: '6', onPressed: () => _onNumberPressed('6'), colors: colors),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NumberButton(number: '7', onPressed: () => _onNumberPressed('7'), colors: colors),
            _NumberButton(number: '8', onPressed: () => _onNumberPressed('8'), colors: colors),
            _NumberButton(number: '9', onPressed: () => _onNumberPressed('9'), colors: colors),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72, height: 72), // Empty space
            _NumberButton(number: '0', onPressed: () => _onNumberPressed('0'), colors: colors),
            _isLoading
                ? SizedBox(
                    width: 72,
                    height: 72,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _NumberButton(
                    icon: Icons.backspace_outlined,
                    onPressed: _onBackspace,
                    colors: colors,
                  ),
          ],
        ),
      ],
    );
  }

  void _onNumberPressed(String number) {
    if (_isLoading || _pin.length >= widget.pinLength) return;

    HapticFeedback.lightImpact();

    setState(() {
      _pin += number;
      _error = null;
    });

    if (_pin.length == widget.pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_isLoading || _pin.isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    try {
      final success = await widget.onConfirm(_pin);

      if (success) {
        if (mounted) {
          Navigator.pop(context, PinConfirmationResult.success);
        }
      } else {
        _attempts++;
        if (_attempts >= widget.maxAttempts) {
          if (mounted) {
            Navigator.pop(context, PinConfirmationResult.failed);
          }
        } else {
          setState(() {
            _pin = '';
            _error = 'Incorrect PIN. ${widget.maxAttempts - _attempts} attempts remaining.';
            _isLoading = false;
          });
          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      setState(() {
        _pin = '';
        _error = 'Something went wrong. Try again.';
        _isLoading = false;
      });
    }
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.filled, required this.colors});

  final bool filled;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: filled ? colors.gold : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? colors.gold : colors.textTertiary,
          width: 2,
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    this.number,
    this.icon,
    required this.onPressed,
    required this.colors,
  });

  final String? number;
  final IconData? icon;
  final VoidCallback onPressed;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: colors.elevated,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: colors.textSecondary, size: 24)
              : AppText(
                  number ?? '',
                  variant: AppTextVariant.headlineMedium,
                  color: colors.textPrimary,
                ),
        ),
      ),
    );
  }
}
