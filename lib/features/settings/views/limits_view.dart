import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class LimitsView extends ConsumerWidget {
  const LimitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Transaction Limits',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Level Badge
            _buildAccountLevelCard(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Daily Limits
            AppText(
              'Daily Limits',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLimitCard(
              colors: colors,
              title: 'Send Money',
              used: 250.00,
              limit: 1000.00,
              icon: Icons.send,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLimitCard(
              colors: colors,
              title: 'Withdraw',
              used: 0.00,
              limit: 500.00,
              icon: Icons.arrow_upward,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLimitCard(
              colors: colors,
              title: 'Deposit',
              used: 500.00,
              limit: 5000.00,
              icon: Icons.arrow_downward,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Monthly Limits
            AppText(
              'Monthly Limits',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLimitCard(
              colors: colors,
              title: 'Total Transactions',
              used: 2450.00,
              limit: 10000.00,
              icon: Icons.swap_horiz,
              isMonthly: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLimitCard(
              colors: colors,
              title: 'International Transfers',
              used: 0.00,
              limit: 2500.00,
              icon: Icons.public,
              isMonthly: true,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Upgrade CTA
            _buildUpgradeCard(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Info Card
            AppCard(
              variant: AppCardVariant.subtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.infoBase, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        'About Limits',
                        variant: AppTextVariant.labelMedium,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    'Limits reset at midnight UTC. Complete KYC verification to increase your limits.',
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

  Widget _buildAccountLevelCard(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold500, AppColors.gold600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.verified,
              color: colors.canvas,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Basic Account',
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  'Complete KYC for higher limits',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitCard({
    required ThemeColors colors,
    required String title,
    required double used,
    required double limit,
    required IconData icon,
    bool isMonthly = false,
  }) {
    final percentage = (used / limit).clamp(0.0, 1.0);
    final remaining = limit - used;
    final isNearLimit = percentage >= 0.8;
    final isAtLimit = percentage >= 1.0;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      variant: AppTextVariant.labelMedium,
                      color: colors.textPrimary,
                    ),
                    AppText(
                      '\$${remaining.toStringAsFixed(2)} remaining',
                      variant: AppTextVariant.bodySmall,
                      color: isAtLimit
                          ? AppColors.errorBase
                          : (isNearLimit ? AppColors.warningBase : colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    '\$${used.toStringAsFixed(2)}',
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    'of \$${limit.toStringAsFixed(2)}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: colors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAtLimit
                    ? AppColors.errorBase
                    : (isNearLimit ? AppColors.warningBase : colors.gold),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.gold.withValues(alpha: 0.15),
            AppColors.gold600.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              color: colors.gold,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Need higher limits?',
                  variant: AppTextVariant.labelLarge,
                  color: colors.gold,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  'Verify your identity to unlock premium limits',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: colors.gold,
          ),
        ],
      ),
    );
  }
}
