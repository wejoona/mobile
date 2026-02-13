import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/pin/widgets/pin_dots.dart';
import 'package:usdc_wallet/features/pin/widgets/pin_pad.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Lock screen — mirrors LoginPinView design exactly.
class SessionLockedView extends ConsumerStatefulWidget {
  const SessionLockedView({super.key});

  @override
  ConsumerState<SessionLockedView> createState() => _SessionLockedViewState();
}

class _SessionLockedViewState extends ConsumerState<SessionLockedView> {
  String _pin = '';
  bool _showError = false;
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
        automaticallyImplyLeading: false,
        title: AppText(
          l10n.session_enterPinToUnlock,
          variant: AppTextVariant.headlineSmall,
          color: colors.textPrimary,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.session_lockedMessage,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              PinDots(
                filledCount: _pin.length,
                showError: _showError,
              ),
              SizedBox(height: AppSpacing.md),
              if (pinState.remainingAttempts < 5) ...[
                AppText(
                  l10n.pin_attemptsRemaining(pinState.remainingAttempts),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.warningText,
                ),
              ],
              const Spacer(),
              AppButton(
                label: l10n.pin_forgotPin,
                onPressed: () => context.push('/pin/reset'),
                variant: AppButtonVariant.ghost,
              ),
              SizedBox(height: AppSpacing.md),
              PinPad(
                onNumberPressed: _handleNumberPressed,
                onBackspace: _handleBackspace,
                onBiometric: (_biometricSupported && _biometricEnabled)
                    ? _handleBiometric
                    : null,
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
        _showError = false;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _showError = false;
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
          _showError = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _pin = '';
              _showError = false;
            });
          }
        });
      }
    }
  }
}
