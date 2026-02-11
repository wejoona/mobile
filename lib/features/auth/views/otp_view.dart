import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/utils/logger.dart';

class OtpView extends ConsumerStatefulWidget {
  const OtpView({super.key});

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> with CodeAutoFill {
  String _otp = '';
  bool _hasError = false;
  bool _isListeningForSms = false;

  // Resend timer
  static const int _resendCooldown = 30; // seconds
  int _resendTimerSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startListeningForSms();
    _startResendTimer();
  }

  @override
  void dispose() {
    cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimerSeconds = _resendCooldown;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() {
          _resendTimerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  bool get _canResend => _resendTimerSeconds == 0;

  void _startListeningForSms() async {
    try {
      await SmsAutoFill().listenForCode();
      setState(() => _isListeningForSms = true);
    } catch (e) {
      AppLogger('SMS autofill not available').error('SMS autofill not available', e);
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      AppLogger('Debug').debug('OTP AuthState changed: ${prev?.status} -> ${next.status}');
      if (next.status == AuthStatus.authenticated) {
        AppLogger('Debug').debug('Authentication successful! Checking PIN...');
        // Check if user has PIN set — if not, go to PIN setup
        final user = next.user;
        final hasPin = user?.hasPin ?? false;
        if (!hasPin) {
          context.go('/pin/setup');
        } else {
          context.go('/home');
        }
      } else if (next.error != null) {
        AppLogger('Debug').debug('OTP verification error: ${next.error}');
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
      backgroundColor: colors.canvas,
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
                        const Spacer(flex: 1),

                        // Shield Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colors.container,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            Icons.security,
                            color: colors.gold,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Title
                        AppText(
                          l10n.auth_secureLogin,
                          variant: AppTextVariant.headlineMedium,
                          color: colors.textPrimary,
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Subtitle
                        AppText(
                          l10n.auth_otpMessage(authState.phone ?? "your phone"),
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
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
                                  color: colors.gold.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                AppText(
                                  l10n.auth_waitingForSms,
                                  variant: AppTextVariant.bodySmall,
                                  color: colors.gold.withValues(alpha: 0.7),
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

                        // Resend code with timer
                        _buildResendButton(colors, authState, l10n),

                        const SizedBox(height: AppSpacing.lg),
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

  Widget _buildResendButton(ThemeColors colors, AuthState authState, AppLocalizations l10n) {
    final isDisabled = !_canResend || authState.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
                if (authState.phone != null) {
                  ref.read(authProvider.notifier).login(authState.phone!);
                  _startResendTimer();
                }
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              _canResend
                  ? l10n.auth_resendCode
                  : '${l10n.auth_resendCode} ($_resendTimerSeconds s)',
              variant: AppTextVariant.bodyMedium,
              color: isDisabled ? colors.textDisabled : colors.gold,
            ),
            if (!_canResend) ...[
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: _resendTimerSeconds / _resendCooldown,
                  strokeWidth: 2,
                  color: colors.gold.withValues(alpha: 0.5),
                  backgroundColor: colors.borderSubtle,
                ),
              ),
            ],
          ],
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
    final storage = ref.read(secureStorageProvider);

    // Check if there's a stored refresh token (user has logged in before)
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);
    if (refreshToken == null) {
      _showBiometricError();
      return;
    }

    // Authenticate with biometric
    final authenticatedBio = await biometricService.authenticate(
      localizedReason: 'Authenticate to access JoonaPay',
    );

    if (authenticatedBio.success) {
      // Use AuthNotifier to handle biometric login (syncs with FSM)
      final success = await ref.read(authProvider.notifier).loginWithBiometric(refreshToken);
      if (!success) {
        _showBiometricError();
      }
      // Navigation happens via the authProvider listener when status becomes authenticated
    } else {
      _showBiometricError();
    }
  }

  void _showBiometricError() {
    setState(() {
      _hasError = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    });
  }
}
