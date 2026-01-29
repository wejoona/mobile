import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/login_provider.dart';
import '../models/login_state.dart';

/// Login OTP verification screen
class LoginOtpView extends ConsumerStatefulWidget {
  const LoginOtpView({super.key});

  @override
  ConsumerState<LoginOtpView> createState() => _LoginOtpViewState();
}

class _LoginOtpViewState extends ConsumerState<LoginOtpView> {
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
    final state = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.login_verifyCode,
                style: AppTypography.headlineLarge,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                l10n.login_codeSentTo(
                  state.countryCode ?? '+225',
                  _formatPhoneForDisplay(state.phoneNumber ?? ''),
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
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
                    color: AppColors.errorBase.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.errorBase),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.errorText),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.errorText,
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
                    ? Text(
                        l10n.login_resendIn(state.otpResendCountdown),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: state.isLoading ? null : _handleResend,
                        child: Text(
                          l10n.login_resendCode,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.gold500,
                          ),
                        ),
                      ),
              ),
              const Spacer(),
              if (state.isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.gold500),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.login_verifying,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
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
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _hasError
              ? AppColors.errorBase
              : _controllers[index].text.isNotEmpty
                  ? AppColors.gold500
                  : AppColors.borderDefault,
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
          color: AppColors.textPrimary,
        ),
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
      ref.read(loginProvider.notifier).updateOtp(otp);
      await ref.read(loginProvider.notifier).verifyOtp();

      if (mounted) {
        final state = ref.read(loginProvider);
        if (state.currentStep == LoginStep.pin) {
          context.go('/login/pin');
        } else if (state.error != null) {
          setState(() => _hasError = true);
          // Clear inputs
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
    await ref.read(loginProvider.notifier).resendOtp();
  }

  String _formatPhoneForDisplay(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)} XX XX XX XX';
  }
}
