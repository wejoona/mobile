import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/pin/widgets/pin_dots.dart';
import 'package:usdc_wallet/features/pin/widgets/pin_pad.dart';
import 'package:usdc_wallet/features/onboarding/providers/onboarding_provider.dart';
import 'package:usdc_wallet/features/onboarding/widgets/onboarding_progress.dart';

/// PIN setup screen for onboarding
class OnboardingPinView extends ConsumerStatefulWidget {
  const OnboardingPinView({super.key});

  @override
  ConsumerState<OnboardingPinView> createState() => _OnboardingPinViewState();
}

class _OnboardingPinViewState extends ConsumerState<OnboardingPinView> {
  String _pin = '';
  String? _confirmPin;
  bool _showError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          _confirmPin == null
              ? l10n.onboarding_pin_title
              : l10n.onboarding_pin_confirmTitle,
          style: AppTypography.headlineSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.icon),
          onPressed: () {
            if (_confirmPin != null) {
              setState(() {
                _confirmPin = null;
                _pin = '';
                _errorMessage = null;
                _showError = false;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Progress indicator
              const OnboardingProgress(currentStep: 4, totalSteps: 5),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                _confirmPin == null
                    ? l10n.onboarding_pin_enterPin
                    : l10n.onboarding_pin_confirmPin,
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              PinDots(
                filledCount: _pin.length,
                showError: _showError,
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: AppSpacing.md),
                AppText(
                  _errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.errorText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              if (_confirmPin == null) _buildValidationRules(l10n, colors),
              const Spacer(),
              if (state.isLoading)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(colors.gold),
                )
              else
                PinPad(
                  onNumberPressed: _handleNumberPressed,
                  onBackspace: _handleBackspace,
                ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationRules(AppLocalizations l10n, ThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.pin_requirements,
            style: AppTypography.labelMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildRule(l10n.pin_rule_6digits, _pin.length == 6, colors),
          _buildRule(l10n.pin_rule_noSequential, !_isSequential(_pin), colors),
          _buildRule(l10n.pin_rule_noRepeated, !_isRepeated(_pin), colors),
        ],
      ),
    );
  }

  Widget _buildRule(String text, bool satisfied, ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: satisfied ? colors.success : colors.textSecondary,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: satisfied ? colors.gold : colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
        _showError = false;
        _errorMessage = null;
      });

      if (_pin.length == 6) {
        if (_confirmPin == null) {
          _validateAndProceedToConfirm();
        } else {
          _validateAndSubmit();
        }
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

  void _validateAndProceedToConfirm() {
    final l10n = AppLocalizations.of(context)!;

    if (_isSequential(_pin)) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_sequential;
      });
      _resetPinAfterError();
      return;
    }

    if (_isRepeated(_pin)) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_repeated;
      });
      _resetPinAfterError();
      return;
    }

    // Valid PIN, move to confirmation
    setState(() {
      _confirmPin = _pin;
      _pin = '';
    });
  }

  void _validateAndSubmit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_pin != _confirmPin) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_mismatch;
      });
      _resetPinAfterError();
      return;
    }

    // PINs match, submit
    await ref.read(onboardingProvider.notifier).submitPin(_pin);

    if (mounted && ref.read(onboardingProvider).error == null) {
      context.go('/onboarding/kyc-prompt');
    }
  }

  void _resetPinAfterError() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _pin = '';
          _showError = false;
          _errorMessage = null;
        });
      }
    });
  }

  bool _isSequential(String pin) {
    if (pin.length < 6) return false;
    final digits = pin.split('').map(int.parse).toList();

    bool ascending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        ascending = false;
        break;
      }
    }
    if (ascending) return true;

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
