import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/features/pin/views/enter_pin_view.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';

/// Session Locked View
/// Shown when session is locked and requires PIN/biometric to unlock
class SessionLockedView extends ConsumerWidget {
  const SessionLockedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessionState = ref.watch(appFsmProvider).session;

    String? reason;
    if (sessionState is SessionLocked) {
      reason = sessionState.reason;
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppSpacing.xxxl),
              Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.gold500,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.session_locked,
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                reason ?? l10n.session_lockedMessage,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              // PIN entry is handled by navigation to EnterPinView, not embedded
              AppButton(
                label: l10n.session_enterPinToUnlock,
                onPressed: () {
                  // Navigate to PIN entry
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EnterPinView(
                        title: l10n.session_enterPinToUnlock,
                        onSuccess: (pin) {
                          ref.read(authProvider.notifier).unlock();
                          ref.read(appFsmProvider.notifier).dispatch(
                                const AppSessionEvent(SessionUnlock()),
                              );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.session_useBiometric,
                onPressed: () {
                  ref.read(appFsmProvider.notifier).dispatch(
                        AppSessionEvent(SessionRequestBiometric(reason: l10n.session_unlockReason)),
                      );
                },
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.common_logout,
                onPressed: () {
                  ref.read(appFsmProvider.notifier).logout();
                },
                variant: AppButtonVariant.ghost,
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
