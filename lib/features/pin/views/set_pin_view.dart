import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';

/// Set PIN View
/// Used during onboarding to create initial PIN
class SetPinView extends ConsumerStatefulWidget {
  const SetPinView({super.key});

  @override
  ConsumerState<SetPinView> createState() => _SetPinViewState();
}

class _SetPinViewState extends ConsumerState<SetPinView> {
  String _pin = '';
  bool _showError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.pin_createTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.lg),
                        AppText(
                          l10n.pin_enterNewPin,
                          variant: AppTextVariant.bodyLarge,
                          color: context.colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        PinDots(length: 6,
                          filled: _pin.length,
                          error: _showError,
                        ),
                        if (_errorMessage != null) ...[
                          SizedBox(height: AppSpacing.md),
                          AppText(
                            _errorMessage!,
                            variant: AppTextVariant.bodyMedium,
                            color: context.colors.errorText,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        SizedBox(height: AppSpacing.xl),
                        _buildValidationRules(l10n),
                        const Spacer(),
                        PinPad(
                          onDigitPressed: _handleNumberPressed,
                          onDeletePressed: _handleBackspace,
                        ),
                        SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildValidationRules(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.pin_requirements,
            variant: AppTextVariant.labelMedium,
            color: context.colors.textSecondary,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildRule(l10n.pin_rule_6digits, _pin.length == 6),
          _buildRule(l10n.pin_rule_noSequential, !_isSequential(_pin)),
          _buildRule(l10n.pin_rule_noRepeated, !_isRepeated(_pin)),
        ],
      ),
    );
  }

  Widget _buildRule(String text, bool satisfied) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: satisfied ? context.colors.successText : context.colors.textTertiary,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: satisfied ? context.colors.textPrimary : context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNumberPressed(int digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit.toString();
        _showError = false;
        _errorMessage = null;
      });

      if (_pin.length == 6) {
        _validateAndProceed();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _showError = false;
        _errorMessage = null;
      });
    }
  }

  void _validateAndProceed() {
    final l10n = AppLocalizations.of(context)!;

    // Validate PIN
    if (_isSequential(_pin)) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_sequential;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _pin = '';
          _showError = false;
          _errorMessage = null;
        });
      });
      return;
    }

    if (_isRepeated(_pin)) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_repeated;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _pin = '';
          _showError = false;
          _errorMessage = null;
        });
      });
      return;
    }

    // Navigate to confirm screen
    context.push('/pin/confirm', extra: _pin);
  }

  bool _isSequential(String pin) {
    if (pin.length < 6) return false;
    final digits = pin.split('').map(int.parse).toList();

    // Check ascending
    bool ascending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        ascending = false;
        break;
      }
    }
    if (ascending) return true;

    // Check descending
    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] - 1) {
        descending = false;
        break;
      }
    }
    return descending;
  }

  bool _isRepeated(String pin) {
    if (pin.length < 6) return false;
    return pin.split('').toSet().length == 1;
  }
}
