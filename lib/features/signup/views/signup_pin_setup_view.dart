import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// PIN setup screen for explicit account signup.
class SignupPinSetupView extends ConsumerStatefulWidget {
  const SignupPinSetupView({super.key});

  @override
  ConsumerState<SignupPinSetupView> createState() => _SignupPinSetupViewState();
}

class _SignupPinSetupViewState extends ConsumerState<SignupPinSetupView> {
  String _pin = '';
  String? _confirmPin;
  bool _showError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(signupFlowProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      AuthTopBar(onBack: _handleBack),
                      const SizedBox(height: AppSpacing.lg),
                      const FlowStepProgress(currentStep: 4, totalSteps: 5),
                      const SizedBox(height: AppSpacing.xxl),
                      AuthScreenHeader(
                        appName: l10n.appName,
                        title: _confirmPin == null
                            ? l10n.onboarding_pin_title
                            : l10n.onboarding_pin_confirmTitle,
                        subtitle: _confirmPin == null
                            ? l10n.onboarding_pin_enterPin
                            : l10n.onboarding_pin_confirmPin,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      PinDots(
                        length: 6,
                        filled: _pin.length,
                        error: _showError,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppText(
                          _errorMessage!,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.errorText,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (state.error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppText(
                          state.error!,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.errorText,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      if (_confirmPin == null)
                        _buildValidationRules(l10n, colors),
                      const Spacer(),
                      if (state.isLoading)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(colors.gold),
                        )
                      else
                        PinPad(
                          onDigitPressed: _handleNumberPressed,
                          onDeletePressed: _handleBackspace,
                          showBiometric: false,
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
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

  void _handleBack() {
    if (_confirmPin != null) {
      setState(() {
        _confirmPin = null;
        _pin = '';
        _errorMessage = null;
        _showError = false;
      });
    } else {
      context.fsmGo('/signup/profile');
    }
  }

  void _handleNumberPressed(int number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number.toString();
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
    await ref.read(signupFlowProvider.notifier).submitPin(_pin);

    if (mounted && ref.read(signupFlowProvider).error == null) {
      context.fsmGo('/signup/kyc-prompt');
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
