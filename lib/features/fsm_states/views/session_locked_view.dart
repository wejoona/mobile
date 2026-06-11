import 'dart:async';

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
import 'package:usdc_wallet/services/session/session_service.dart';
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
  bool _biometricEnabled = false;
  BiometricType _biometricType = BiometricType.none;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBiometric());
  }

  Future<void> _checkBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    final isEnabled = await biometricService.isBiometricEnabled();
    final type = await biometricService.getAvailableType();

    if (mounted) {
      setState(() {
        _biometricEnabled = isEnabled;
        _biometricType = type;
      });

      // Biometric is user-initiated only — no auto-fire
    }
  }

  void _unlock() {
    if (_isUnlocking || !mounted) {
      return;
    }
    setState(() => _isUnlocking = true);

    Future.delayed(const Duration(milliseconds: 360), () {
      if (!mounted) {
        return;
      }
      final router = GoRouter.of(context);
      ref.read(authProvider.notifier).unlock();
      ref.read(sessionServiceProvider.notifier).unlockSession();
      ref
          .read(appFsmProvider.notifier)
          .dispatch(const AppSessionEvent(SessionUnlock()));
      router.go('/home');
    });
  }

  Future<void> _logout() async {
    try {
      await ref.read(authProvider.notifier).logout();
    } on Object {
      await ref.read(authProvider.notifier).clearLocalSession();
    }
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pinState = ref.watch(pinStateProvider);
    final colors = context.colors;

    if (_isUnlocking) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_open_rounded, size: 48, color: colors.gold),
                    const SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.pin_unlocked,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => unawaited(_logout()),
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                            l10n.pin_attemptsRemaining(
                              pinState.remainingAttempts,
                            ),
                            variant: AppTextVariant.bodyMedium,
                            color: colors.warningText,
                          ),

                        const Spacer(flex: 1),

                        // PIN Pad — design system version with biometric
                        PinPad(
                          onDigitPressed: (digit) => _handleDigitPressed(digit),
                          onDeletePressed: _handleDeletePressed,
                          showBiometric: _shouldShowBiometricUnlock,
                          biometricIcon: _biometricIcon,
                          onBiometricPressed: _shouldShowBiometricUnlock
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
    if (_pin.length >= 6) {
      return;
    }

    setState(() {
      _pin += digit.toString();
      _hasError = false;
    });

    if (_pin.length == 6) {
      unawaited(_verifyPin());
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
    final l10n = AppLocalizations.of(context)!;
    final result = await biometricService.authenticate(
      localizedReason: l10n.session_unlockReason,
    );

    if (mounted && result.success) {
      _unlock();
    }
  }

  bool get _shouldShowBiometricUnlock => _biometricEnabled;

  IconData get _biometricIcon {
    switch (_biometricType) {
      case BiometricType.faceId:
        return Icons.face_rounded;
      case BiometricType.fingerprint:
      case BiometricType.iris:
      case BiometricType.none:
        return Icons.fingerprint_rounded;
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
