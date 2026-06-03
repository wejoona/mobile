import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Simple spending breakdown chart (horizontal bars).
class SpendingChart extends StatelessWidget {
  final List<SpendingSummary> categories;
  final double totalSpent;

  const SpendingChart({
    super.key,
    required this.categories,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final sorted = List<SpendingSummary>.from(categories)
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final maxAmount = sorted.isNotEmpty ? sorted.first.totalAmount : 1.0;

    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final category in sorted.take(8)) ...[
            _CategoryBar(
              category: category,
              maxAmount: maxAmount,
              theme: theme,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final SpendingSummary category;
  final double maxAmount;
  final ThemeData theme;
  final ThemeColors colors;

  const _CategoryBar({
    required this.category,
    required this.maxAmount,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount > 0
        ? (category.totalAmount / maxAmount).clamp(0.0, 1.0)
        : 0.0;
    final color = _categoryColor(context, category.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ExpenseCategories.label(category.category),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            AmountText.fromText(
              '${formatXof(category.totalAmount)} (${category.percentageOfTotal.toStringAsFixed(0)}%)',
              size: AmountTextSize.small,
              color: colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: colors.elevated),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _categoryColor(BuildContext context, String category) {
    switch (category) {
      case 'transport':
        return colors.info;
      case 'food':
        return colors.warning;
      case 'utilities':
        return colors.infoText;
      case 'telecom':
        return AppColors.gold400;
      case 'health':
        return colors.error;
      case 'education':
        return AppColors.gold700;
      case 'shopping':
        return colors.errorText;
      case 'entertainment':
        return colors.gold;
      case 'transfers':
        return colors.infoText;
      case 'bills':
        return colors.warningText;
      case 'savings':
        return colors.success;
      default:
        return colors.textTertiary;
    }
  }
}

/// Donut chart summary widget.
class SpendingSummaryHeader extends StatelessWidget {
  final double totalSpent;
  final double totalReceived;
  final String currency;

  const SpendingSummaryHeader({
    super.key,
    required this.totalSpent,
    required this.totalReceived,
    this.currency = 'USDC',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final netFlow = totalReceived - totalSpent;
    final isPositive = netFlow >= 0;

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FlowItem(
              label: l10n.insights_total_spent,
              amount: totalSpent,
              color: colors.errorText,
              currency: currency,
            ),
            Container(width: 1, height: 40, color: colors.borderSubtle),
            _FlowItem(
              label: l10n.insights_total_received,
              amount: totalReceived,
              color: colors.successText,
              currency: currency,
            ),
            Container(width: 1, height: 40, color: colors.borderSubtle),
            _FlowItem(
              label: l10n.insights_net_flow,
              amount: netFlow.abs(),
              color: isPositive ? colors.successText : colors.errorText,
              currency: currency,
              prefix: isPositive ? '+' : '-',
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String currency;
  final String prefix;

  const _FlowItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.currency,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        AmountText.fromText(
          '$prefix${formatXof(amount)}',
          size: AmountTextSize.small,
          color: color,
        ),
      ],
    );
  }
}
