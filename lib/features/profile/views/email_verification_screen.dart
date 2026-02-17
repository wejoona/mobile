import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Email verification screen — 6-digit OTP input
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _hasError = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) timer.cancel();
      });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    final code = _otp;
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      await userService.verifyEmail(code);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Update user state
      ref.read(userStateMachineProvider.notifier).updateProfile(
        emailVerified: true,
      );

      // Pop back after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Code invalide. Veuillez réessayer.';
      });
      _clearOtp();
    }
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
  }

  Future<void> _resend() async {
    final email = ref.read(userStateMachineProvider).email;
    if (email == null) return;

    try {
      final userService = ref.read(userServiceProvider);
      await userService.resendEmailVerification(email);
      _startResendCountdown();
    } catch (_) {
      // Silently fail
    }
  }

  void _handleOtpChange(String value, int index) {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _submit();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);
    final email = userState.email ?? '';

    if (_isSuccess) {
      return _buildSuccessView(colors);
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: AppText(
          'Vérification email',
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              AppText(
                'Un code a été envoyé à',
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                email,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _buildOtpBox(i, colors)),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: colors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.errorText, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          _errorMessage!,
                          variant: AppTextVariant.bodySmall,
                          color: colors.errorText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Resend
              Center(
                child: _resendCountdown > 0
                    ? AppText(
                        'Renvoyer le code dans ${_resendCountdown}s',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      )
                    : AppButton(
                        label: 'Renvoyer le code',
                        onPressed: _resend,
                        variant: AppButtonVariant.ghost,
                      ),
              ),

              const Spacer(),

              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colors.gold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, ThemeColors colors) {
    return SizedBox(
      width: 48,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _hasError
                ? colors.error
                : _controllers[index].text.isNotEmpty
                    ? colors.gold
                    : colors.border,
            width: _controllers[index].text.isNotEmpty ? 2 : 1,
          ),
        ),
        child: Center(
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
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeColors colors) {
    return Scaffold(
      backgroundColor: colors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: colors.success, size: 48),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              'Email vérifié ✅',
              variant: AppTextVariant.headlineMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'Votre adresse email a été vérifiée avec succès.',
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
