import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../pin/widgets/pin_dots.dart';
import '../../pin/widgets/pin_pad.dart';
import '../providers/onboarding_provider.dart';

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

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          _confirmPin == null
              ? l10n.onboarding_pin_title
              : l10n.onboarding_pin_confirmTitle,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              SizedBox(height: AppSpacing.xxl),
              Text(
                _confirmPin == null
                    ? l10n.onboarding_pin_enterPin
                    : l10n.onboarding_pin_confirmPin,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
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
                Text(
                  _errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.errorText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              if (_confirmPin == null) _buildValidationRules(l10n),
              const Spacer(),
              if (state.isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.gold500),
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

  Widget _buildValidationRules(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pin_requirements,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
            color: satisfied ? AppColors.successText : AppColors.textTertiary,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: satisfied ? AppColors.textPrimary : AppColors.textTertiary,
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
      context.go('/onboarding/profile');
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
