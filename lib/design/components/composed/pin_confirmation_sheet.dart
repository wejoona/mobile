import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Result of PIN confirmation
enum PinConfirmationResult { success, cancelled, failed }

/// A bottom sheet for PIN confirmation on sensitive operations
class PinConfirmationSheet extends StatefulWidget {
  const PinConfirmationSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.amount,
    this.currencyCode = 'USDC',
    this.recipient,
    required this.onConfirm,
    this.pinLength = 6,
    this.maxAttempts = 3,
  });

  final String title;
  final String? subtitle;
  final double? amount;
  final String currencyCode;
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
    String currencyCode = 'USDC',
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
        currencyCode: currencyCode,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
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
                child: Icon(Icons.lock_outline, color: colors.gold, size: 32),
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
                              l10n.common_amount,
                              variant: AppTextVariant.bodyMedium,
                              color: colors.textSecondary,
                            ),
                            AmountText.fromText(
                              formatCurrency(
                                widget.amount!,
                                widget.currencyCode,
                              ),
                              size: AmountTextSize.small,
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
                              l10n.send_recipient,
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

              SecurityCodeDots(
                length: widget.pinLength,
                filled: _pin.length,
                error: _error != null,
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

              SecurityNumberPad(
                onDigitPressed: (digit) => _onNumberPressed('$digit'),
                onDeletePressed: _onBackspace,
                isLoading: _isLoading,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Cancel button
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context, PinConfirmationResult.cancelled);
                      },
                child: AppText(
                  l10n.action_cancel,
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

  void _onNumberPressed(String number) {
    if (_isLoading || _pin.length >= widget.pinLength) return;

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
            _error =
                'Incorrect PIN. ${widget.maxAttempts - _attempts} attempts remaining.';
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
