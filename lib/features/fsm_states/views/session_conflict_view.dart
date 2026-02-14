import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Session Conflict View
/// Shown when user is logged in on another device
class SessionConflictView extends ConsumerStatefulWidget {
  const SessionConflictView({super.key});

  @override
  ConsumerState<SessionConflictView> createState() => _SessionConflictViewState();
}

class _SessionConflictViewState extends ConsumerState<SessionConflictView> {
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionState = ref.watch(appFsmProvider).session;

    String? conflictingDeviceId;
    if (sessionState is SessionConflict) {
      conflictingDeviceId = sessionState.conflictingDeviceId;
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.devices,
                size: 80,
                color: context.colors.warning,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.session_conflict,
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.session_conflictMessage,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (conflictingDeviceId != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.smartphone, color: context.colors.gold),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              l10n.session_otherDevice,
                              variant: AppTextVariant.labelSmall,
                              color: context.colors.textSecondary,
                            ),
                            AppText(
                              conflictingDeviceId.substring(0,
                                conflictingDeviceId.length > 20 ? 20 : conflictingDeviceId.length),
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              AppCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 40,
                      color: context.colors.warning,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.session_forceLogoutWarning,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.session_continueHere,
                onPressed: _isResolving ? null : _resolveConflict,
                isLoading: _isResolving,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resolveConflict() async {
    setState(() => _isResolving = true);
    try {
      ref.read(appFsmProvider.notifier).dispatch(
            const AppSessionEvent(SessionResolveConflict()),
          );
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }
}
