import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/auth/widgets/otp_progress_cue.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';

class OtpView extends ConsumerStatefulWidget {
  const OtpView({super.key});

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> with CodeAutoFill {
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'otp-keyboard');
  String _otp = '';
  bool _hasError = false;
  bool _isListeningForSms = false;
  bool _isSubmittingOtp = false;
  DateTime? _otpSubmittedAt;

  // Resend timer
  static const int _resendCooldown = 30; // seconds
  int _resendTimerSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_startListeningForSms());
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    unawaited(cancel());
    _resendTimer?.cancel();
    _keyboardFocusNode.dispose();
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

  Future<void> _startListeningForSms() async {
    try {
      await SmsAutoFill().listenForCode();
      setState(() => _isListeningForSms = true);
    } catch (e) {
      AppLogger(
        'SMS autofill not available',
      ).error('SMS autofill not available', e);
    }
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length == 6) {
      setState(() {
        _otp = code!;
      });
      unawaited(_verifyOtp());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final isBusy = authState.isLoading || _isSubmittingOtp;
    final otpCueLabel = _localizedOtpCopy(
      context,
      en: 'Code accepted. Securing your session...',
      fr: 'Code accepté. Sécurisation de la session...',
    );
    // Biometric quick-login: show fingerprint button if both available and enabled
    final biometricAvailable =
        ref.watch(biometricAvailableProvider).value ?? false;
    final biometricEnabled = ref.watch(biometricEnabledProvider).value ?? false;
    final showBiometricOption = biometricAvailable && biometricEnabled;

    ref.listen<AuthState>(authProvider, (prev, next) {
      AppLogger(
        'Debug',
      ).debug('OTP AuthState changed: ${prev?.status} -> ${next.status}');
      if (next.status == AuthStatus.authenticated) {
        unawaited(_finishAuthenticatedOtp(next));
      } else if (next.error != null) {
        AppLogger('Debug').debug('OTP verification error: ${next.error}');
        setState(() {
          _hasError = true;
          _isSubmittingOtp = false;
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
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
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
                            const SizedBox(height: AppSpacing.lg),
                            AuthTopBar(onBack: () => context.go('/login')),
                            const SizedBox(height: AppSpacing.xl),
                            AuthScreenHeader(
                              appName: l10n.appName,
                              title: l10n.auth_secureLogin,
                              subtitle: l10n.auth_otpMessage(
                                authState.phone ?? "your phone",
                              ),
                            ),

                            // SMS autofill indicator
                            if (_isListeningForSms)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
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

                            // PIN Pad — no biometric on OTP screen
                            KeyboardListener(
                              focusNode: _keyboardFocusNode,
                              autofocus: true,
                              onKeyEvent: _handleKeyEvent,
                              child: PinPad(
                                onDigitPressed: (digit) =>
                                    _onDigitPressed(digit),
                                onDeletePressed: _onDeletePressed,
                                showBiometric: false,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xxl),

                            // Resend code with timer
                            _buildResendButton(colors, authState, l10n),

                            if (EnvironmentConfig.showDevOtpShortcut) ...[
                              const SizedBox(height: AppSpacing.sm),
                              AppButton(
                                label: 'Use dev OTP',
                                onPressed: isBusy
                                    ? null
                                    : () {
                                        setState(() => _otp = '123456');
                                        unawaited(_verifyOtp());
                                      },
                                variant: AppButtonVariant.ghost,
                              ),
                            ],

                            // Biometric quick-login option
                            if (showBiometricOption) ...[
                              const SizedBox(height: AppSpacing.lg),
                              TextButton.icon(
                                onPressed: isBusy
                                    ? null
                                    : _authenticateWithBiometric,
                                icon: Icon(
                                  Icons.fingerprint,
                                  color: colors.gold,
                                ),
                                label: AppText(
                                  l10n.auth_useBiometric,
                                  variant: AppTextVariant.bodyMedium,
                                  color: colors.gold,
                                ),
                              ),
                            ],

                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            OtpVerificationOverlay(visible: isBusy, label: otpCueLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildResendButton(
    ThemeColors colors,
    AuthState authState,
    AppLocalizations l10n,
  ) {
    final isDisabled = !_canResend || authState.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
                if (authState.phone != null) {
                  unawaited(
                    ref.read(authProvider.notifier).login(authState.phone!),
                  );
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
    if (ref.read(authProvider).isLoading || _isSubmittingOtp) return;
    if (_otp.length >= 6) return;

    setState(() {
      _otp += digit.toString();
    });

    if (_otp.length == 6) {
      unawaited(_verifyOtp());
    }
  }

  void _onDeletePressed() {
    if (_otp.isEmpty) return;

    setState(() {
      _otp = _otp.substring(0, _otp.length - 1);
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || ref.read(authProvider).isLoading) {
      return;
    }

    final character = event.character;
    if (character != null && RegExp(r'^\d$').hasMatch(character)) {
      _onDigitPressed(int.parse(character));
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace ||
        event.logicalKey == LogicalKeyboardKey.delete) {
      _onDeletePressed();
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_otp.length == 6) {
        unawaited(_verifyOtp());
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_isSubmittingOtp || ref.read(authProvider).isLoading) return;
    setState(() {
      _isSubmittingOtp = true;
      _hasError = false;
      _otpSubmittedAt = DateTime.now();
    });
    await ref.read(authProvider.notifier).verifyOtp(_otp);
    if (mounted && ref.read(authProvider).status != AuthStatus.authenticated) {
      setState(() => _isSubmittingOtp = false);
    }
  }

  Future<void> _finishAuthenticatedOtp(AuthState authState) async {
    await _holdOtpCue(_otpSubmittedAt);
    if (!mounted || ref.read(authProvider).status != AuthStatus.authenticated) {
      return;
    }

    AppLogger('Debug').debug('Authentication successful! Checking PIN...');
    final user = authState.user;
    final hasPin = user?.hasPin ?? false;
    if (!hasPin) {
      context.go('/pin/setup');
    } else {
      context.enterAuthenticatedApp();
    }
  }

  Future<void> _holdOtpCue(DateTime? submittedAt) async {
    if (submittedAt == null) {
      return;
    }
    const minimumCueDuration = Duration(milliseconds: 1600);
    final elapsed = DateTime.now().difference(submittedAt);
    if (elapsed < minimumCueDuration) {
      await Future<void>.delayed(minimumCueDuration - elapsed);
    }
  }

  String _localizedOtpCopy(
    BuildContext context, {
    required String en,
    required String fr,
  }) {
    return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
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
      localizedReason: AppStrings.authenticateToAccess,
    );

    if (authenticatedBio.success) {
      // Use AuthNotifier to handle biometric login (syncs with FSM)
      final success = await ref
          .read(authProvider.notifier)
          .loginWithBiometric(refreshToken);
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
