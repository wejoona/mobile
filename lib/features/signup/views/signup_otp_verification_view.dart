import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/auth/widgets/otp_progress_cue.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Phone OTP verification screen for explicit account signup.
class SignupOtpVerificationView extends ConsumerStatefulWidget {
  const SignupOtpVerificationView({super.key});

  @override
  ConsumerState<SignupOtpVerificationView> createState() =>
      _SignupOtpVerificationViewState();
}

class _SignupOtpVerificationViewState
    extends ConsumerState<SignupOtpVerificationView> {
  Key _codeInputKey = UniqueKey();
  bool _hasError = false;
  bool _isSubmittingOtp = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(signupFlowProvider);
    final colors = context.colors;
    final isBusy = state.isLoading || _isSubmittingOtp;
    final otpCueLabel = _localizedOtpCopy(
      context,
      en: 'Verifying code. Creating your secure wallet...',
      fr: 'Vérification du code. Création de votre wallet sécurisé...',
    );

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        AuthTopBar(onBack: () => context.fsmGo('/signup')),
                        const SizedBox(height: AppSpacing.lg),
                        const FlowStepProgress(currentStep: 2, totalSteps: 5),
                        const SizedBox(height: AppSpacing.xxl),
                        AuthScreenHeader(
                          appName: l10n.appName,
                          title: l10n.onboarding_otp_title,
                          subtitle: l10n.onboarding_otp_subtitle(
                            state.dialCode ?? '+225',
                            _formatPhoneForDisplay(
                              state.phoneNumber ?? '',
                              state.dialCode ?? '+225',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        SecurityCodeFields(
                          key: _codeInputKey,
                          obscureText: false,
                          hasError: _hasError,
                          enabled: !isBusy,
                          onChanged: (code) {
                            if (_hasError) {
                              setState(() => _hasError = false);
                            }
                          },
                          onCompleted: _submitOtp,
                        ),
                        if (state.error != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.errorBg,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: colors.error),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colors.errorText,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: AppText(
                                    state.error!,
                                    variant: AppTextVariant.bodySmall,
                                    color: colors.errorText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: state.otpResendCountdown > 0
                              ? AppText(
                                  l10n.onboarding_otp_resendIn(
                                    state.otpResendCountdown,
                                  ),
                                  variant: AppTextVariant.bodyMedium,
                                  color: colors.textSecondary,
                                )
                              : AppButton(
                                  label: l10n.onboarding_otp_resend,
                                  onPressed: isBusy ? null : _handleResend,
                                  variant: AppButtonVariant.ghost,
                                ),
                        ),
                        if (EnvironmentConfig.showDevOtpShortcut) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: AppButton(
                              label: 'Use dev OTP',
                              onPressed: isBusy
                                  ? null
                                  : () => _submitOtp('123456'),
                              variant: AppButtonVariant.ghost,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            OtpVerificationOverlay(visible: isBusy, label: otpCueLabel),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOtp(String otp) async {
    if (otp.length == 6) {
      final submittedAt = DateTime.now();
      setState(() {
        _isSubmittingOtp = true;
        _hasError = false;
      });
      ref.read(signupFlowProvider.notifier).updateOtp(otp);
      await ref.read(signupFlowProvider.notifier).verifyOtp();
      await _holdOtpCue(submittedAt);

      if (mounted) {
        final state = ref.read(signupFlowProvider);
        if (state.error == null) {
          await _goToNextStep();
        } else {
          setState(() {
            _hasError = true;
            _isSubmittingOtp = false;
          });
          // Clear inputs and shake
          _clearOtp();
        }
      }
    }
  }

  Future<void> _holdOtpCue(DateTime submittedAt) async {
    const minimumCueDuration = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().difference(submittedAt);
    if (elapsed < minimumCueDuration) {
      await Future<void>.delayed(minimumCueDuration - elapsed);
    }
  }

  void _clearOtp() {
    setState(() {
      _codeInputKey = UniqueKey();
    });
  }

  Future<void> _handleResend() async {
    await ref.read(signupFlowProvider.notifier).resendOtp();
  }

  Future<void> _goToNextStep() async {
    final signupState = ref.read(signupFlowProvider);
    if (signupState.requiresLoginPin) {
      if (mounted) {
        context.fsmGo('/login/pin');
      }
      return;
    }

    final user = ref.read(auth.authProvider).user;
    final hasName = user?.firstName?.trim().isNotEmpty ?? false;
    final hasPin = user?.hasPin ?? false;

    if (hasName && hasPin) {
      await ref.read(signupFlowProvider.notifier).completeSignupFlow();
      if (mounted) context.fsmEnterAuthenticatedApp();
      return;
    }

    if (!mounted) return;
    context.fsmGo(hasName ? '/signup/set-pin' : '/signup/profile');
  }

  String _formatPhoneForDisplay(String phone, String dialCode) {
    final local = localPhoneDigits(dialCode: dialCode, phoneNumber: phone);
    if (local.length < 4) return local;
    return '${local.substring(0, 2)} XX XX XX XX';
  }

  String _localizedOtpCopy(
    BuildContext context, {
    required String en,
    required String fr,
  }) {
    return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
  }
}
