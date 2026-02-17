import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class SpendingSummaryCard extends ConsumerWidget {
  const SpendingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(spendingSummaryProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.insights_error(e.toString()))),
      data: (summary) => _buildCard(context, l10n, summary),
    );
  }

  Widget _buildCard(BuildContext context, AppLocalizations l10n, Map<String, dynamic> summary) {
    final percentageChange = (summary['percentageChange'] as num?)?.toDouble() ?? 0.0;
    final isIncrease = (summary['isIncrease'] as bool?) ?? false;
    final totalSpent = (summary['totalSpent'] as num?)?.toDouble() ?? 0.0;
    final totalReceived = (summary['totalReceived'] as num?)?.toDouble() ?? 0.0;
    final netFlow = (summary['netFlow'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.container,
            context.colors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colors.borderGold,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.insights_summary,
                variant: AppTextVariant.titleMedium,
                color: context.colors.textPrimary,
              ),
              if (percentageChange > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isIncrease
                        ? context.colors.error.withValues(alpha: 0.2)
                        : context.colors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isIncrease
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: isIncrease
                            ? context.colors.errorText
                            : context.colors.successText,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        '${percentageChange.toStringAsFixed(1)}%',
                        variant: AppTextVariant.bodySmall,
                        color: isIncrease
                            ? context.colors.errorText
                            : context.colors.successText,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Total spent
          _buildStatItem(
            l10n.insights_total_spent,
            '\$${totalSpent.toStringAsFixed(2)}',
            context.colors.errorText,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Total received
          _buildStatItem(
            l10n.insights_total_received,
            '\$${totalReceived.toStringAsFixed(2)}',
            context.colors.successText,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          Container(
            height: 1,
            color: context.colors.borderSubtle,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Net flow
          _buildStatItem(
            l10n.insights_net_flow,
            '${netFlow >= 0 ? '+' : ''}\$${netFlow.toStringAsFixed(2)}',
            netFlow >= 0 ? context.colors.successText : context.colors.errorText,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor, {
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: AppText(
            value,
            variant: isLarge ? AppTextVariant.headlineSmall : AppTextVariant.titleMedium,
            color: valueColor,
            fontWeight: FontWeight.bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
