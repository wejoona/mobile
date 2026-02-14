import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';

/// Login PIN verification screen — same design as OTP/lock screens.
class LoginPinView extends ConsumerStatefulWidget {
  const LoginPinView({super.key});

  @override
  ConsumerState<LoginPinView> createState() => _LoginPinViewState();
}

class _LoginPinViewState extends ConsumerState<LoginPinView> {
  String _pin = '';
  bool _hasError = false;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    final canCheck = await biometricService.canCheckBiometrics();
    final isEnabled = await biometricService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _biometricSupported = canCheck;
        _biometricEnabled = isEnabled;
      });

      if (_biometricSupported && _biometricEnabled) {
        _handleBiometric();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginProvider);
    final colors = context.colors;

    if (state.isLocked) {
      return _buildLockedView(l10n, colors);
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.login_enterPin,
          variant: AppTextVariant.headlineSmall,
          color: colors.textPrimary,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colors.container,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: colors.gold,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        AppText(
                          l10n.login_pinSubtitle,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.xxxl),

                        // PIN Dots
                        PinDots(
                          length: 6,
                          filled: _pin.length,
                          error: _hasError,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        if (state.pinAttempts > 0 && state.remainingAttempts > 0)
                          AppText(
                            l10n.login_attemptsRemaining(state.remainingAttempts),
                            variant: AppTextVariant.bodyMedium,
                            color: colors.warningText,
                          ),

                        if (state.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppText(
                            state.error!,
                            variant: AppTextVariant.bodySmall,
                            color: colors.errorText,
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const Spacer(flex: 1),

                        // PIN Pad
                        PinPad(
                          onDigitPressed: _handleDigitPressed,
                          onDeletePressed: _handleDeletePressed,
                          showBiometric: _biometricSupported && _biometricEnabled,
                          onBiometricPressed: (_biometricSupported && _biometricEnabled)
                              ? _handleBiometric
                              : null,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        TextButton(
                          onPressed: () => context.push('/pin/reset'),
                          child: AppText(
                            l10n.login_forgotPin,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.gold,
                          ),
                        ),

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

  Widget _buildLockedView(AppLocalizations l10n, ThemeColors colors) {
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.container,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(
                    Icons.lock_clock,
                    color: colors.error,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppText(
                  l10n.login_accountLocked,
                  variant: AppTextVariant.headlineMedium,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.login_lockedMessage,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.common_ok,
                  onPressed: () => context.go('/login'),
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDigitPressed(int digit) {
    if (_pin.length >= 6) return;

    setState(() {
      _pin += digit.toString();
      _hasError = false;
    });

    if (_pin.length == 6) {
      _verifyPin();
    }
  }

  void _handleDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
      });
    }
  }

  Future<void> _handleBiometric() async {
    final success = await ref.read(loginProvider.notifier).verifyBiometric();

    if (mounted && success) {
      context.go('/home');
    }
  }

  Future<void> _verifyPin() async {
    final success = await ref.read(loginProvider.notifier).verifyPin(_pin);

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        setState(() => _hasError = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _pin = '';
              _hasError = false;
            });
          }
        });
      }
    }
  }
}
