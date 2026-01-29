import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../pin/widgets/pin_dots.dart';
import '../../pin/widgets/pin_pad.dart';
import '../providers/login_provider.dart';
import '../models/login_state.dart';
import '../../../services/biometric/biometric_service.dart';

/// Login PIN verification screen
class LoginPinView extends ConsumerStatefulWidget {
  const LoginPinView({super.key});

  @override
  ConsumerState<LoginPinView> createState() => _LoginPinViewState();
}

class _LoginPinViewState extends ConsumerState<LoginPinView> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginProvider);

    // Check if locked
    if (state.isLocked) {
      return _buildLockedView(l10n);
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          l10n.login_enterPin,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.login_pinSubtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              PinDots(
                filledCount: _pin.length,
                showError: _showError,
              ),
              SizedBox(height: AppSpacing.md),
              if (state.pinAttempts > 0 && state.remainingAttempts > 0) ...[
                Text(
                  l10n.login_attemptsRemaining(state.remainingAttempts),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warningText,
                  ),
                ),
              ],
              if (state.error != null) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  state.error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.errorText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/pin/reset'),
                child: Text(
                  l10n.login_forgotPin,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.gold500,
                  ),
                ),
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

  Widget _buildLockedView(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppColors.errorText,
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.login_accountLocked,
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  l10n.login_lockedMessage,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.common_ok,
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
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
