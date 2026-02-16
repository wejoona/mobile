import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Biometric Prompt View — themed lock screen with Face ID / Touch ID.
/// Matches the native Korido security overlay design.
class BiometricPromptView extends ConsumerStatefulWidget {
  const BiometricPromptView({super.key});

  @override
  ConsumerState<BiometricPromptView> createState() => _BiometricPromptViewState();
}

class _BiometricPromptViewState extends ConsumerState<BiometricPromptView> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _hasFailed = false;

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _hasFailed = false;
    });
    final l10n = AppLocalizations.of(context)!;

    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        if (mounted) _fallbackToPin();
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
          ref.read(authProvider.notifier).unlock();
          ref.read(appFsmProvider.notifier).dispatch(
                const AppSessionEvent(SessionBiometricSuccess()),
              );
        } else {
          setState(() => _hasFailed = true);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _hasFailed = true);
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _fallbackToPin() {
    ref.read(appFsmProvider.notifier).dispatch(
          const AppSessionEvent(SessionLock(reason: 'Biometric unavailable')),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);
    final firstName = userState.firstName ?? '';
    final avatarUrl = userState.effectiveAvatarUrl;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // App logo — matching native overlay
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_icon.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // "Korido"
            Text(
              'Korido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Greeting
            Text(
              firstName.isNotEmpty
                  ? 'Bon retour, $firstName'
                  : 'Bon retour',
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 3),

            // Face ID button
            GestureDetector(
              onTap: _isAuthenticating ? null : _authenticateWithBiometric,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.container,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _hasFailed
                        ? colors.error.withValues(alpha: 0.5)
                        : colors.gold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.face_rounded,
                  size: 36,
                  color: _hasFailed ? colors.error : colors.gold,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              _hasFailed ? 'Réessayer' : 'Face ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _hasFailed ? colors.error : colors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Use PIN instead
            TextButton(
              onPressed: _fallbackToPin,
              child: Text(
                'Utiliser le code PIN',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.gold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
