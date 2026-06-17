import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/features/auth/models/login_state.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/auth/widgets/otp_progress_cue.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Login OTP verification screen
class LoginOtpView extends ConsumerStatefulWidget {
  const LoginOtpView({super.key});

  @override
  ConsumerState<LoginOtpView> createState() => _LoginOtpViewState();
}

class _LoginOtpViewState extends ConsumerState<LoginOtpView> {
  Key _codeInputKey = UniqueKey();
  bool _hasError = false;
  bool _isSubmittingOtp = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginProvider);
    final colors = context.colors;
    final isBusy = state.isLoading || _isSubmittingOtp;
    final otpCueLabel = _localizedOtpCopy(
      context,
      en: 'Code accepted. Securing your session...',
      fr: 'Code accepté. Sécurisation de la session...',
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
                        AuthTopBar(onBack: () => context.go('/login')),
                        const SizedBox(height: AppSpacing.xl),
                        AuthScreenHeader(
                          appName: l10n.appName,
                          title: l10n.login_verifyCode,
                          subtitle: l10n.login_codeSentTo(
                            state.dialCode ?? '+225',
                            _formatPhoneForDisplay(
                              state.phoneNumber ?? '',
                              dialCode: state.dialCode,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        SecurityCodeFields(
                          key: _codeInputKey,
                          obscureText: false,
                          hasError: _hasError,
                          enabled: !isBusy,
                          onChanged: (_) {
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
                              color: colors.error.withValues(alpha: 0.1),
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
                                  l10n.login_resendIn(state.otpResendCountdown),
                                  variant: AppTextVariant.bodyMedium,
                                  color: colors.textSecondary,
                                )
                              : AppButton(
                                  label: l10n.login_resendCode,
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
      ref.read(loginProvider.notifier).updateOtp(otp);
      await ref.read(loginProvider.notifier).verifyOtp();
      await _holdOtpCue(submittedAt);

      if (mounted) {
        final state = ref.read(loginProvider);
        if (state.currentStep == LoginStep.pin) {
          context.go('/login/pin');
        } else if (state.error != null) {
          setState(() {
            _hasError = true;
            _isSubmittingOtp = false;
          });
          // Clear inputs
          _clearOtp();
        } else {
          setState(() => _isSubmittingOtp = false);
        }
      }
    }
  }

  Future<void> _holdOtpCue(DateTime submittedAt) async {
    const minimumCueDuration = Duration(milliseconds: 1600);
    final elapsed = DateTime.now().difference(submittedAt);
    if (elapsed < minimumCueDuration) {
      await Future<void>.delayed(minimumCueDuration - elapsed);
    }
  }

  void _clearOtp() {
    setState(() => _codeInputKey = UniqueKey());
  }

  Future<void> _handleResend() async {
    await ref.read(loginProvider.notifier).resendOtp();
  }

  String _formatPhoneForDisplay(String phone, {String? dialCode}) {
    final localPhone = localPhoneDigits(
      dialCode: dialCode ?? '+225',
      phoneNumber: phone,
    );
    if (localPhone.length < 4) return localPhone;
    return '${localPhone.substring(0, 2)} XX XX XX XX';
  }

  String _localizedOtpCopy(
    BuildContext context, {
    required String en,
    required String fr,
  }) {
    return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
  }
}
