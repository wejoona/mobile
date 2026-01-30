import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/onboarding_progress_provider.dart';

/// Prompt encouraging first deposit
class FirstDepositPrompt extends ConsumerWidget {
  const FirstDepositPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(onboardingProgressProvider);

    // Don't show if already completed or dismissed
    if (!progress.shouldShowDepositPrompt) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.goldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.goldGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.add_card_rounded,
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
                      l10n.onboarding_deposit_prompt_title,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textInverse,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      l10n.onboarding_deposit_prompt_subtitle,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textInverse.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ref
                    .read(onboardingProgressProvider.notifier)
                    .dismissPrompt('deposit_prompt'),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: colors.textInverse,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Benefits
          _buildBenefit(
            Icons.flash_on_rounded,
            l10n.onboarding_deposit_benefit1,
            colors,
          ),
          _buildBenefit(
            Icons.account_balance_rounded,
            l10n.onboarding_deposit_benefit2,
            colors,
          ),
          _buildBenefit(
            Icons.security_rounded,
            l10n.onboarding_deposit_benefit3,
            colors,
          ),
          const SizedBox(height: AppSpacing.lg),

          // CTA Button
          AppButton(
            label: l10n.onboarding_deposit_cta,
            onPressed: () {
              ref
                  .read(onboardingProgressProvider.notifier)
                  .dismissPrompt('deposit_prompt');
              context.push('/deposit');
            },
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            backgroundColor: Colors.white,
            textColor: AppColors.gold500,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: colors.textInverse, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: colors.textInverse.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
