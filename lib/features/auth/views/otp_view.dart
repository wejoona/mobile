import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../services/biometric/biometric_service.dart';
import '../providers/auth_provider.dart';

class OtpView extends ConsumerStatefulWidget {
  const OtpView({super.key});

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> with CodeAutoFill {
  String _otp = '';
  bool _hasError = false;
  bool _isListeningForSms = false;

  @override
  void initState() {
    super.initState();
    _startListeningForSms();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  void _startListeningForSms() async {
    try {
      await SmsAutoFill().listenForCode();
      setState(() => _isListeningForSms = true);
    } catch (e) {
      debugPrint('SMS autofill not available: $e');
    }
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length == 6) {
      setState(() {
        _otp = code!;
      });
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      debugPrint('OTP AuthState changed: ${prev?.status} -> ${next.status}');
      if (next.status == AuthStatus.authenticated) {
        debugPrint('Authentication successful! Navigating to /home...');
        context.go('/home');
      } else if (next.error != null) {
        debugPrint('OTP verification error: ${next.error}');
        setState(() {
          _hasError = true;
          _otp = '';
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _hasError = false;
            });
          }
        });
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Shield Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Icon(
                  Icons.security,
                  color: AppColors.gold500,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              const AppText(
                'Secure Login',
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textPrimary,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              AppText(
                'Enter the 6-digit code sent to ${authState.phone ?? "your phone"}',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),

              // SMS autofill indicator
              if (_isListeningForSms)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sms,
                        size: 16,
                        color: AppColors.gold500.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AppText(
                        'Waiting for SMS...',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.gold500.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xxxl),

              // PIN Dots
              PinDots(
                length: 6,
                filled: _otp.length,
                error: _hasError,
              ),

              const Spacer(flex: 1),

              // PIN Pad with Biometric
              biometricAvailable.when(
                data: (available) => biometricEnabled.when(
                  data: (enabled) => PinPad(
                    onDigitPressed: (digit) => _onDigitPressed(digit),
                    onDeletePressed: _onDeletePressed,
                    showBiometric: available && enabled,
                    onBiometricPressed: available && enabled
                        ? () => _authenticateWithBiometric()
                        : null,
                  ),
                  loading: () => PinPad(
                    onDigitPressed: (digit) => _onDigitPressed(digit),
                    onDeletePressed: _onDeletePressed,
                    showBiometric: false,
                  ),
                  error: (_, __) => PinPad(
                    onDigitPressed: (digit) => _onDigitPressed(digit),
                    onDeletePressed: _onDeletePressed,
                    showBiometric: false,
                  ),
                ),
                loading: () => PinPad(
                  onDigitPressed: (digit) => _onDigitPressed(digit),
                  onDeletePressed: _onDeletePressed,
                  showBiometric: false,
                ),
                error: (_, __) => PinPad(
                  onDigitPressed: (digit) => _onDigitPressed(digit),
                  onDeletePressed: _onDeletePressed,
                  showBiometric: false,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Resend code
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        if (authState.phone != null) {
                          ref
                              .read(authProvider.notifier)
                              .login(authState.phone!);
                        }
                      },
                child: const AppText(
                  'Resend Code',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.gold500,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _onDigitPressed(int digit) {
    if (_otp.length >= 6) return;

    setState(() {
      _otp += digit.toString();
    });

    if (_otp.length == 6) {
      _verifyOtp();
    }
  }

  void _onDeletePressed() {
    if (_otp.isEmpty) return;

    setState(() {
      _otp = _otp.substring(0, _otp.length - 1);
    });
  }

  Future<void> _verifyOtp() async {
    await ref.read(authProvider.notifier).verifyOtp(_otp);
  }

  Future<void> _authenticateWithBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);

    final authenticated = await biometricService.authenticate(
      reason: 'Authenticate to access JoonaPay',
    );

    if (authenticated) {
      // If biometric auth successful, we can skip OTP for returning users
      // This requires a stored token check
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.checkAuth();
    }
  }
}
