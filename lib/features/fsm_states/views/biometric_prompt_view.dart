import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Biometric Prompt View
/// Shown when biometric authentication is required
class BiometricPromptView extends ConsumerStatefulWidget {
  const BiometricPromptView({super.key});

  @override
  ConsumerState<BiometricPromptView> createState() => _BiometricPromptViewState();
}

class _BiometricPromptViewState extends ConsumerState<BiometricPromptView> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Auto-prompt biometric on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometric();
    });
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        if (mounted) {
          ref.read(appFsmProvider.notifier).dispatch(
                const AppSessionEvent(SessionBiometricFailed()),
              );
        }
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: l10n.biometric_authenticateReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (mounted) {
        if (didAuthenticate) {
          ref.read(appFsmProvider.notifier).dispatch(
                const AppSessionEvent(SessionBiometricSuccess()),
              );
        } else {
          ref.read(appFsmProvider.notifier).dispatch(
                const AppSessionEvent(SessionBiometricFailed()),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(appFsmProvider.notifier).dispatch(
              const AppSessionEvent(SessionBiometricFailed()),
            );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionState = ref.watch(appFsmProvider).session;

    String reason = l10n.biometric_promptReason;
    if (sessionState is SessionBiometricPrompt) {
      reason = sessionState.reason;
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 100,
                color: AppColors.gold500,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.biometric_promptTitle,
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                reason,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              if (_isAuthenticating)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
                ),
              if (!_isAuthenticating) ...[
                AppButton(
                  label: l10n.biometric_tryAgain,
                  onPressed: _authenticateWithBiometric,
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.biometric_usePinInstead,
                  onPressed: () {
                    ref.read(appFsmProvider.notifier).dispatch(
                          const AppSessionEvent(SessionLock(reason: 'Biometric cancelled')),
                        );
                  },
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
