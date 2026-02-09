import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_progress.dart';

/// OTP verification screen
class OtpVerificationView extends ConsumerStatefulWidget {
  const OtpVerificationView({super.key});

  @override
  ConsumerState<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _hasError = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.icon),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              const OnboardingProgress(currentStep: 2, totalSteps: 5),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.onboarding_otp_title,
                style: AppTypography.headlineLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.onboarding_otp_subtitle(
                  state.countryCode ?? '+225',
                  _formatPhoneForDisplay(state.phoneNumber ?? ''),
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              // OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildOtpBox(index),
                ),
              ),
              if (state.error != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.errorBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: colors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.errorText),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          state.error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.errorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xxl),
              // Resend code
              Center(
                child: state.otpResendCountdown > 0
                    ? AppText(
                        l10n.onboarding_otp_resendIn(state.otpResendCountdown),
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: state.isLoading ? null : _handleResend,
                        child: AppText(
                          l10n.onboarding_otp_resend,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.gold,
                          ),
                        ),
                      ),
              ),
              const Spacer(),
              if (state.isLoading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(colors.gold),
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.onboarding_otp_verifying,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final colors = context.colors;
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _hasError
              ? colors.error
              : _controllers[index].text.isNotEmpty
                  ? colors.gold
                  : colors.borderSubtle,
          width: _controllers[index].text.isNotEmpty ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTypography.headlineMedium.copyWith(
          color: colors.textPrimary,
        ),
        cursorColor: colors.gold,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _handleOtpChange(value, index),
      ),
    );
  }

  void _handleOtpChange(String value, int index) {
    setState(() => _hasError = false);

    if (value.isNotEmpty) {
      // Move to next box
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered, submit
        _submitOtp();
      }
    } else {
      // Move to previous box on delete
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _submitOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      ref.read(onboardingProvider.notifier).updateOtp(otp);
      await ref.read(onboardingProvider.notifier).verifyOtp();

      if (mounted) {
        final state = ref.read(onboardingProvider);
        if (state.error == null) {
          context.go('/onboarding/profile');
        } else {
          setState(() => _hasError = true);
          // Clear inputs and shake
          _clearOtp();
        }
      }
    }
  }

  void _clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _handleResend() async {
    await ref.read(onboardingProvider.notifier).resendOtp();
  }

  String _formatPhoneForDisplay(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)} XX XX XX XX';
  }
}
