import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/limits_provider.dart';
import '../widgets/limit_card.dart';
import '../widgets/upgrade_prompt.dart';

class LimitsView extends ConsumerStatefulWidget {
  const LimitsView({super.key});

  @override
  ConsumerState<LimitsView> createState() => _LimitsViewState();
}

class _LimitsViewState extends ConsumerState<LimitsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(limitsProvider.notifier).fetchLimits());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(limitsProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.limits_title,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.gold),
            onPressed: () => ref.read(limitsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.gold),
            )
          : state.error != null
              ? _buildError(context, l10n, colors, state.error!)
              : state.limits == null
                  ? _buildEmpty(context, l10n, colors)
                  : _buildContent(context, l10n, colors),
    );
  }

  Widget _buildError(BuildContext context, AppLocalizations l10n, ThemeColors colors, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorBase),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.error_generic,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.action_retry,
              onPressed: () => ref.read(limitsProvider.notifier).refresh(),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n, ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.limits_noData,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ThemeColors colors) {
    final limits = ref.watch(limitsProvider).limits!;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(limitsProvider.notifier).refresh();
      },
      color: colors.gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Level Badge
            _buildAccountLevelCard(context, l10n, colors, limits.tierName, limits.kycTier),
            const SizedBox(height: AppSpacing.xxl),

            // Daily Limits Section
            AppText(
              l10n.limits_dailyLimits,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            LimitCard(
              title: l10n.limits_dailyTransactions,
              used: limits.dailyUsed,
              limit: limits.dailyLimit,
              icon: Icons.swap_horiz,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Monthly Limits Section
            AppText(
              l10n.limits_monthlyLimits,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            LimitCard(
              title: l10n.limits_monthlyTransactions,
              used: limits.monthlyUsed,
              limit: limits.monthlyLimit,
              icon: Icons.calendar_today,
              isMonthly: true,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Upgrade CTA (only show if there's a next tier)
            if (limits.hasNextTier) ...[
              UpgradePrompt(
                nextTierName: limits.nextTierName,
                nextTierDailyLimit: limits.nextTierDailyLimit,
                nextTierMonthlyLimit: limits.nextTierMonthlyLimit,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],

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
                        l10n.limits_aboutTitle,
                        variant: AppTextVariant.labelMedium,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    l10n.limits_aboutDescription,
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

  Widget _buildAccountLevelCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    String tierName,
    int kycTier,
  ) {
    IconData getTierIcon() {
      switch (kycTier) {
        case 0:
          return Icons.account_circle_outlined;
        case 1:
          return Icons.verified_outlined;
        case 2:
          return Icons.verified;
        case 3:
          return Icons.stars;
        default:
          return Icons.account_circle_outlined;
      }
    }

    return GestureDetector(
      onTap: () => context.push('/kyc'),
      child: AppCard(
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
                getTierIcon(),
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
                    tierName,
                    variant: AppTextVariant.titleMedium,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    kycTier < 3
                        ? l10n.limits_kycPrompt
                        : l10n.limits_maxTier,
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
      ),
    );
  }
}
