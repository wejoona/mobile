import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';

class LoadingView extends ConsumerStatefulWidget {
  const LoadingView({super.key});

  @override
  ConsumerState<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends ConsumerState<LoadingView> {
  Timer? _timeoutTimer;
  bool _showRetry = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _showRetry = true);
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isRetrying = true;
      _showRetry = false;
    });

    try {
      await ref.read(walletStateMachineProvider.notifier).fetch(force: true);
      await ref.read(kycStateMachineProvider.notifier).fetch();
    } catch (e) {
      debugPrint('[LoadingView] Retry error: $e');
    }

    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isRetrying = false;
        _showRetry = true;
      });
    }
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    ref.read(appFsmProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final appState = ref.watch(appFsmProvider);
    final walletState = ref.watch(walletStateMachineProvider);

    final hasError = walletState.status == WalletStatus.error ||
        walletState.error != null;

    // Show retry immediately on error
    final showRetryNow = _showRetry || hasError;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _handleLogout,
            child: AppText(
              l10n.common_logout,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon — same style as lock/OTP screens
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.container,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                  ),
                  child: hasError
                      ? Icon(Icons.error_outline, color: colors.error, size: 40)
                      : SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: colors.gold,
                            strokeWidth: 2.5,
                          ),
                        ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppText(
                  hasError
                      ? l10n.common_error
                      : 'Chargement de votre compte...',
                  variant: AppTextVariant.headlineMedium,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                AppText(
                  hasError
                      ? (walletState.error ?? l10n.common_errorTryAgain)
                      : 'Veuillez patienter pendant que nous récupérons vos données.',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),

                // Debug info (debug mode only)
                if (kDebugMode) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText('FSM: ${appState.name}', variant: AppTextVariant.bodySmall),
                        AppText('Wallet: ${walletState.status.name}', variant: AppTextVariant.bodySmall),
                        AppText('KYC: ${appState.kyc.name}', variant: AppTextVariant.bodySmall),
                        if (walletState.error != null)
                          AppText('Erreur : ${walletState.error}', variant: AppTextVariant.bodySmall, color: colors.error),
                      ],
                    ),
                  ),
                ],

                // Retry
                if (showRetryNow && !_isRetrying) ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  AppButton(
                    label: l10n.common_retry,
                    variant: AppButtonVariant.primary,
                    onPressed: _handleRetry,
                    isFullWidth: true,
                  ),
                ],

                if (_isRetrying) ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: colors.gold,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
