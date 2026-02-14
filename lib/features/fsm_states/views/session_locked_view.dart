import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Lock screen — same design as OTP/login screens.
/// Uses the design system PinDots + PinPad for consistency.
class SessionLockedView extends ConsumerStatefulWidget {
  const SessionLockedView({super.key});

  @override
  ConsumerState<SessionLockedView> createState() => _SessionLockedViewState();
}

class _SessionLockedViewState extends ConsumerState<SessionLockedView> {
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

      // Auto-show biometric if enabled
      if (_biometricSupported && _biometricEnabled) {
        _handleBiometric();
      }
    }
  }

  void _unlock() {
    ref.read(authProvider.notifier).unlock();
    ref.read(appFsmProvider.notifier).dispatch(
          const AppSessionEvent(SessionUnlock()),
        );
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    ref.read(appFsmProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pinState = ref.watch(pinStateProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _logout,
            child: AppText(
              l10n.common_logout,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ),
        ],
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

                        // Lock Icon — same style as OTP shield icon
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

                        // Title
                        AppText(
                          l10n.session_enterPinToUnlock,
                          variant: AppTextVariant.headlineMedium,
                          color: colors.textPrimary,
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Subtitle
                        AppText(
                          l10n.session_lockedMessage,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.xxxl),

                        // PIN Dots — design system version
                        PinDots(
                          length: 6,
                          filled: _pin.length,
                          error: _hasError,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Attempts warning
                        if (pinState.remainingAttempts < 5)
                          AppText(
                            l10n.pin_attemptsRemaining(pinState.remainingAttempts),
                            variant: AppTextVariant.bodyMedium,
                            color: colors.warningText,
                          ),

                        const Spacer(flex: 1),

                        // PIN Pad — design system version with biometric
                        PinPad(
                          onDigitPressed: (digit) => _handleDigitPressed(digit),
                          onDeletePressed: _handleDeletePressed,
                          showBiometric: _biometricSupported && _biometricEnabled,
                          onBiometricPressed: (_biometricSupported && _biometricEnabled)
                              ? _handleBiometric
                              : null,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Forgot PIN
                        TextButton(
                          onPressed: () => context.push('/pin/reset'),
                          child: AppText(
                            l10n.pin_forgotPin,
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
    final biometricService = ref.read(biometricServiceProvider);
    final result = await biometricService.authenticate(
      localizedReason: 'Déverrouillez Korido',
    );

    if (mounted && result.success) {
      _unlock();
    }
  }

  Future<void> _verifyPin() async {
    final success = await ref.read(pinStateProvider.notifier).verifyPin(_pin);

    if (mounted) {
      if (success) {
        _unlock();
      } else {
        setState(() {
          _hasError = true;
        });
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
