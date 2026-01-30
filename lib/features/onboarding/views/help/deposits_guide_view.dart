import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design/tokens/index.dart';
import '../../../../design/components/primitives/index.dart';
import '../../../../l10n/app_localizations.dart';

/// Guide explaining how deposits work
class DepositsGuideView extends ConsumerWidget {
  const DepositsGuideView({super.key});

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
          l10n.help_howDepositsWork,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppText(
              l10n.help_deposits_header,
              variant: AppTextVariant.headlineMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.help_deposits_intro,
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Step by step guide
            AppText(
              l10n.help_deposits_steps_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildStep(
              '1',
              l10n.help_deposits_step1_title,
              l10n.help_deposits_step1_description,
              Icons.account_balance_wallet_rounded,
              colors,
            ),
            _buildStep(
              '2',
              l10n.help_deposits_step2_title,
              l10n.help_deposits_step2_description,
              Icons.smartphone_rounded,
              colors,
            ),
            _buildStep(
              '3',
              l10n.help_deposits_step3_title,
              l10n.help_deposits_step3_description,
              Icons.numbers_rounded,
              colors,
            ),
            _buildStep(
              '4',
              l10n.help_deposits_step4_title,
              l10n.help_deposits_step4_description,
              Icons.check_circle_rounded,
              colors,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Supported providers
            AppText(
              l10n.help_deposits_providers_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildProvider('Orange Money', '🟠', colors),
            _buildProvider('MTN Mobile Money', '🟡', colors),
            _buildProvider('Wave', '🔵', colors),
            _buildProvider('Moov Money', '🔴', colors),
            const SizedBox(height: AppSpacing.xxl),

            // Processing time
            Container(
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
                      gradient: const LinearGradient(colors: AppColors.goldGradient),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: colors.textInverse,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.help_deposits_time_title,
                          variant: AppTextVariant.labelLarge,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          l10n.help_deposits_time_description,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // FAQ
            AppText(
              l10n.help_deposits_faq_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFaqItem(
              l10n.help_deposits_faq1_question,
              l10n.help_deposits_faq1_answer,
              colors,
            ),
            _buildFaqItem(
              l10n.help_deposits_faq2_question,
              l10n.help_deposits_faq2_answer,
              colors,
            ),
            _buildFaqItem(
              l10n.help_deposits_faq3_question,
              l10n.help_deposits_faq3_answer,
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    String number,
    String title,
    String description,
    IconData icon,
    ThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.goldGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold500.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: AppText(
                number,
                variant: AppTextVariant.titleLarge,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: colors.gold, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppText(
                        title,
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
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

  Widget _buildProvider(String name, String emoji, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            AppText(
              name,
              variant: AppTextVariant.bodyMedium,
              color: colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              question,
              variant: AppTextVariant.labelMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              answer,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
