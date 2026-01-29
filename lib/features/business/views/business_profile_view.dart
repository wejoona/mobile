import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/account_type.dart';
import '../providers/business_provider.dart';

/// Business Profile View - view and edit business info
class BusinessProfileView extends ConsumerWidget {
  const BusinessProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(businessProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.business_profileTitle,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colors.gold),
            onPressed: () => context.push('/settings/business-setup'),
          ),
        ],
      ),
      body: state.businessProfile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.business_noProfile,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.business_setupNow,
                    onPressed: () => context.push('/settings/business-setup'),
                  ),
                ],
              ),
            )
          : _buildProfileContent(context, ref, l10n, colors, state),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
    BusinessState state,
  ) {
    final profile = state.businessProfile!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification Status
          Container(
            decoration: BoxDecoration(
              color: profile.isVerified
                  ? colors.successBg
                  : colors.warningBg,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: profile.isVerified
                    ? colors.success
                    : colors.warning,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Icon(
                  profile.isVerified
                      ? Icons.verified
                      : Icons.hourglass_top,
                  color: profile.isVerified
                      ? colors.success
                      : colors.warning,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        profile.isVerified
                            ? l10n.business_verified
                            : l10n.business_verificationPending,
                        variant: AppTextVariant.titleSmall,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        profile.isVerified
                            ? l10n.business_verifiedDescription
                            : l10n.business_verificationPendingDescription,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Business Information
          AppText(
            l10n.business_information,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),

          _InfoTile(
            icon: Icons.business,
            label: l10n.business_businessName,
            value: profile.businessName,
          ),
          _InfoTile(
            icon: Icons.category,
            label: l10n.business_businessType,
            value: profile.businessType.displayName,
          ),
          if (profile.registrationNumber != null)
            _InfoTile(
              icon: Icons.numbers,
              label: l10n.business_registrationNumber,
              value: profile.registrationNumber!,
            ),
          if (profile.businessAddress != null)
            _InfoTile(
              icon: Icons.location_on,
              label: l10n.business_businessAddress,
              value: profile.businessAddress!,
            ),
          if (profile.taxId != null)
            _InfoTile(
              icon: Icons.receipt_long,
              label: l10n.business_taxId,
              value: profile.taxId!,
            ),

          const SizedBox(height: AppSpacing.xxl),

          // KYB Section
          if (!profile.isVerified) ...[
            AppCard(
              variant: AppCardVariant.goldAccent,
              onTap: () => _showKybInfo(context, l10n),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.verified_user,
                      color: colors.gold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.business_completeVerification,
                          variant: AppTextVariant.titleSmall,
                          color: colors.gold,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          l10n.business_kybDescription,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.gold,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showKybInfo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.colors.container,
        title: AppText(
          l10n.business_kybTitle,
          variant: AppTextVariant.titleMedium,
          color: dialogContext.colors.textPrimary,
        ),
        content: AppText(
          l10n.business_kybInfo,
          variant: AppTextVariant.bodyMedium,
          color: dialogContext.colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              l10n.action_close,
              variant: AppTextVariant.labelLarge,
              color: dialogContext.colors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.textTertiary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.labelSmall,
                  color: colors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  value,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
