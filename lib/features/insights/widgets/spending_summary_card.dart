import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

class SpendingSummaryCard extends ConsumerWidget {
  const SpendingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(spendingSummaryProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: AppText(
          AppLocalizations.of(context)!.insights_error(UserFacingErrors.message(e)),
          textAlign: TextAlign.center,
        ),
      ),
      data: (summary) => _buildCard(context, l10n, summary),
    );
  }

  Widget _buildCard(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> summary,
  ) {
    final colors = context.colors;
    final percentageChange =
        (summary['percentageChange'] as num?)?.toDouble() ?? 0.0;
    final isIncrease = (summary['isIncrease'] as bool?) ?? false;
    final totalSpent = (summary['totalSpent'] as num?)?.toDouble() ?? 0.0;
    final totalReceived = (summary['totalReceived'] as num?)?.toDouble() ?? 0.0;
    final netFlow = (summary['netFlow'] as num?)?.toDouble() ?? 0.0;

    return AppCard(
      variant: AppCardVariant.flat,
      borderColor: colors.borderGold,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
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
                StatusPill(
                  label: '${percentageChange.toStringAsFixed(1)}%',
                  tone: isIncrease ? StatusTone.danger : StatusTone.success,
                  icon: isIncrease
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  compact: true,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Total spent
          _buildStatItem(
            l10n.insights_total_spent,
            formatXof(totalSpent),
            colors.errorText,
            colors,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Total received
          _buildStatItem(
            l10n.insights_total_received,
            formatXof(totalReceived),
            colors.successText,
            colors,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          Container(height: 1, color: colors.borderSubtle),

          const SizedBox(height: AppSpacing.lg),

          // Net flow
          _buildStatItem(
            l10n.insights_net_flow,
            '${netFlow >= 0 ? '+' : '-'}${formatXof(netFlow.abs())}',
            netFlow >= 0 ? colors.successText : colors.errorText,
            colors,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    ThemeColors colors, {
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: AmountText.fromText(
            value,
            size: isLarge ? AmountTextSize.medium : AmountTextSize.small,
            color: valueColor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
