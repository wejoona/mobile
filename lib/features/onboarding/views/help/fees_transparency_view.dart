import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Transparent fee breakdown view
class FeesTransparencyView extends ConsumerWidget {
  const FeesTransparencyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: AppText(
          l10n.help_transactionFees,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No hidden fees banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: context.colors.goldGradient,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: colors.textInverse,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.help_fees_no_hidden_title,
                          variant: AppTextVariant.titleMedium,
                          color: colors.textInverse,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          l10n.help_fees_no_hidden_description,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textInverse.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Fee breakdown
            AppText(
              l10n.help_fees_breakdown_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildFeeCard(
              l10n.help_fees_internal_transfers,
              l10n.help_fees_free,
              l10n.help_fees_internal_description,
              Icons.swap_horiz_rounded,
              colors.success,
              colors,
            ),
            _buildFeeCard(
              l10n.help_fees_deposits,
              l10n.help_fees_deposits_amount,
              l10n.help_fees_deposits_description,
              Icons.arrow_downward_rounded,
              colors.gold,
              colors,
            ),
            _buildFeeCard(
              l10n.help_fees_withdrawals,
              l10n.help_fees_withdrawals_amount,
              l10n.help_fees_withdrawals_description,
              Icons.arrow_upward_rounded,
              colors.gold,
              colors,
            ),
            _buildFeeCard(
              l10n.help_fees_external_transfers,
              l10n.help_fees_external_amount,
              l10n.help_fees_external_description,
              Icons.send_rounded,
              context.colors.info,
              colors,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Why we charge fees
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: colors.gold,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        l10n.help_fees_why_title,
                        variant: AppTextVariant.titleSmall,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    l10n.help_fees_why_description,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildWhyPoint(l10n.help_fees_why_point1, colors),
                  _buildWhyPoint(l10n.help_fees_why_point2, colors),
                  _buildWhyPoint(l10n.help_fees_why_point3, colors),
                  _buildWhyPoint(l10n.help_fees_why_point4, colors),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Fee comparison
            AppText(
              l10n.help_fees_comparison_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.help_fees_comparison_description,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildComparisonRow(
              l10n.help_fees_comparison_traditional,
              '3-5%',
              false,
              colors,
            ),
            _buildComparisonRow(
              l10n.help_fees_comparison_joonapay,
              '1%',
              true,
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCard(
    String title,
    String fee,
    String description,
    IconData icon,
    Color accentColor,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          title,
                          variant: AppTextVariant.labelLarge,
                          color: colors.textPrimary,
                        ),
                      ),
                      AppText(
                        fee,
                        variant: AppTextVariant.titleSmall,
                        color: accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    description,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyPoint(String text, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String fee,
    bool isKorido,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isKorido
              ? colors.gold.withValues(alpha: 0.1)
              : colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isKorido
                ? colors.gold.withValues(alpha: 0.3)
                : colors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (isKorido)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.star_rounded,
                      color: colors.gold,
                      size: 20,
                    ),
                  ),
                AppText(
                  label,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ],
            ),
            AppText(
              fee,
              variant: AppTextVariant.labelLarge,
              color: isKorido ? colors.gold : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
