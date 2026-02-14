import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Auth Locked View — consistent with lock/OTP screen design.
class AuthLockedView extends ConsumerStatefulWidget {
  const AuthLockedView({super.key});

  @override
  ConsumerState<AuthLockedView> createState() => _AuthLockedViewState();
}

class _AuthLockedViewState extends ConsumerState<AuthLockedView> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final authState = ref.read(appFsmProvider).auth;
    if (authState is AuthLocked) {
      _remainingSeconds = authState.remainingTime.inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(appFsmProvider).auth;
    final colors = context.colors;

    String reason = l10n.auth_lockedReason;
    if (authState is AuthLocked) {
      reason = authState.reason;
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  Icons.lock_clock,
                  color: colors.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.auth_accountLocked,
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                reason,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    AppText(
                      l10n.auth_tryAgainIn,
                      variant: AppTextVariant.labelMedium,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      _formatDuration(_remainingSeconds),
                      variant: AppTextVariant.displaySmall,
                      color: colors.gold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.common_backToLogin,
                onPressed: () {
                  ref.read(appFsmProvider.notifier).logout();
                },
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
