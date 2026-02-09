import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';

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
    // Show retry button after 10 seconds
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _showRetry = true);
      }
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

    // Re-trigger wallet and KYC fetch
    try {
      await ref.read(walletStateMachineProvider.notifier).refresh();
      await ref.read(kycStateMachineProvider.notifier).fetch();
    } on Exception catch (e) {
      debugPrint('[LoadingView] Retry error: $e');
    }

    // Wait a bit then show retry again if still loading
    await Future<void>.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _isRetrying = false;
        _showRetry = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final appState = ref.watch(appFsmProvider);
    final walletState = ref.watch(walletStateMachineProvider);
    final kycState = ref.watch(kycStateMachineProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading spinner
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: colors.gold,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const AppText(
                  'Loading your account...',
                  variant: AppTextVariant.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppText(
                  'Please wait while we fetch your wallet and verification status.',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),

                // Debug info (only in debug mode)
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
                      AppText(
                        'Debug Info',
                        variant: AppTextVariant.labelSmall,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppText(
                        'FSM: ${appState.name}',
                        variant: AppTextVariant.bodySmall,
                      ),
                      AppText(
                        'Wallet: ${walletState.status.name}',
                        variant: AppTextVariant.bodySmall,
                      ),
                      AppText(
                        'KYC Machine: ${kycState.status.name}',
                        variant: AppTextVariant.bodySmall,
                      ),
                      if (walletState.error != null)
                        AppText(
                          'Wallet Error: ${walletState.error}',
                          variant: AppTextVariant.bodySmall,
                          color: colors.error,
                        ),
                      if (kycState.error != null)
                        AppText(
                          'KYC Error: ${kycState.error}',
                          variant: AppTextVariant.bodySmall,
                          color: colors.error,
                        ),
                    ],
                  ),
                ),

                // Retry button
                if (_showRetry && !_isRetrying) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  AppText(
                    'Taking longer than expected?',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Retry',
                    variant: AppButtonVariant.secondary,
                    onPressed: _handleRetry,
                  ),
                ],

                if (_isRetrying) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  AppText(
                    'Retrying...',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
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
