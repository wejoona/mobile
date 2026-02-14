import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/kyc_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// KYC Expired View
/// Shown when KYC documents have expired and need renewal
class KycExpiredView extends ConsumerWidget {
  const KycExpiredView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final kycState = ref.watch(appFsmProvider).kyc;

    KycTier expiredTier = KycTier.tier1;
    DateTime? expiredAt;

    if (kycState is KycExpired) {
      expiredTier = kycState.previousTier;
      expiredAt = kycState.expiredAt;
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.kyc_expired,
          variant: AppTextVariant.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.xxxl),
                    Icon(
                      Icons.assignment_late,
                      size: 80,
                      color: context.colors.warning,
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    AppText(
                      l10n.kyc_expiredTitle,
                      variant: AppTextVariant.headlineMedium,
                      color: context.colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.kyc_expiredMessage,
                      variant: AppTextVariant.bodyLarge,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    if (expiredAt != null) ...[
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
                              l10n.kyc_expiredOn,
                              variant: AppTextVariant.labelSmall,
                              color: context.colors.textSecondary,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            AppText(
                              _formatDate(expiredAt),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            l10n.kyc_renewalRequired,
                            variant: AppTextVariant.bodyMedium,
                            color: context.colors.textPrimary,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          AppText(
                            l10n.kyc_renewalMessage,
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            l10n.kyc_currentRestrictions,
                            variant: AppTextVariant.bodyMedium,
                            color: context.colors.textPrimary,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          _buildBulletPoint(l10n.kyc_restriction1),
                          _buildBulletPoint(l10n.kyc_restriction2),
                          _buildBulletPoint(l10n.kyc_restriction3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  AppButton(
                    label: l10n.kyc_renewDocuments,
                    onPressed: () {
                      // Navigate to KYC flow
                      context.push('/kyc');
                    },
                    isFullWidth: true,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.kyc_remindLater,
                    onPressed: () => Navigator.of(context).pop(),
                    variant: AppButtonVariant.secondary,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('• ', variant: AppTextVariant.bodySmall, color: AppColors.gold500),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
