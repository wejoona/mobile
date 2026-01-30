import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design/tokens/index.dart';
import '../../../../design/components/primitives/index.dart';
import '../../../../l10n/app_localizations.dart';

/// USDC explainer screen for new users
class UsdcExplainerView extends ConsumerWidget {
  const UsdcExplainerView({super.key});

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
          l10n.help_whatIsUsdc,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.goldGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 40,
                      color: AppColors.gold500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.help_usdc_title,
                    variant: AppTextVariant.headlineMedium,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    l10n.help_usdc_subtitle,
                    variant: AppTextVariant.bodyMedium,
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // What is USDC
            _buildSection(
              l10n.help_usdc_what_title,
              l10n.help_usdc_what_description,
              Icons.info_rounded,
              colors,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Why USDC
            AppText(
              l10n.help_usdc_why_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBenefit(
              Icons.trending_flat_rounded,
              l10n.help_usdc_benefit1_title,
              l10n.help_usdc_benefit1_description,
              colors,
            ),
            _buildBenefit(
              Icons.security_rounded,
              l10n.help_usdc_benefit2_title,
              l10n.help_usdc_benefit2_description,
              colors,
            ),
            _buildBenefit(
              Icons.language_rounded,
              l10n.help_usdc_benefit3_title,
              l10n.help_usdc_benefit3_description,
              colors,
            ),
            _buildBenefit(
              Icons.schedule_rounded,
              l10n.help_usdc_benefit4_title,
              l10n.help_usdc_benefit4_description,
              colors,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // How it works
            _buildSection(
              l10n.help_usdc_how_title,
              l10n.help_usdc_how_description,
              Icons.settings_rounded,
              colors,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Safety info
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: colors.success,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.help_usdc_safety_title,
                          variant: AppTextVariant.labelLarge,
                          color: colors.successText,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          l10n.help_usdc_safety_description,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    IconData icon,
    ThemeColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.gold, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  description,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(
    IconData icon,
    String title,
    String description,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.goldGradient),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: 2),
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
    );
  }
}
