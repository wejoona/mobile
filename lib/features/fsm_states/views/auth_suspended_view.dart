import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Auth Suspended View
/// Shown when account has been suspended by admin
class AuthSuspendedView extends ConsumerWidget {
  const AuthSuspendedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(appFsmProvider).auth;

    String reason = l10n.auth_suspendedReason;
    bool isPermanent = true;
    DateTime? suspendedUntil;

    if (authState is AuthSuspended) {
      reason = authState.reason;
      isPermanent = authState.isPermanent;
      suspendedUntil = authState.suspendedUntil;
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
                Icons.block,
                size: 80,
                color: AppColors.error,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.auth_accountSuspended,
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                reason,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (!isPermanent && suspendedUntil != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      AppText(
                        l10n.auth_suspendedUntil,
                        variant: AppTextVariant.labelSmall,
                        color: context.colors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        _formatDate(suspendedUntil),
                        variant: AppTextVariant.bodyLarge,
                        color: context.colors.gold,
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
                      Icons.support_agent,
                      size: 40,
                      color: context.colors.gold,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.auth_contactSupport,
                      variant: AppTextVariant.bodyMedium,
                      color: context.colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.auth_suspendedContactMessage,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.common_contactSupport,
                onPressed: () => _launchSupport(),
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.common_backToLogin,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchSupport() async {
    final uri = Uri.parse('mailto:support@joonapay.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
