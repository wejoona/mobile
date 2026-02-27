import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';

/// Simple spending breakdown chart (horizontal bars).
class SpendingChart extends StatelessWidget {
  final List<SpendingSummary> categories;
  final double totalSpent;

  const SpendingChart({super.key, required this.categories, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<SpendingSummary>.from(categories)..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final maxAmount = sorted.isNotEmpty ? sorted.first.totalAmount : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in sorted.take(8)) ...[
          _CategoryBar(category: category, maxAmount: maxAmount, theme: theme),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final SpendingSummary category;
  final double maxAmount;
  final ThemeData theme;

  const _CategoryBar({required this.category, required this.maxAmount, required this.theme});

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount > 0 ? (category.totalAmount / maxAmount).clamp(0.0, 1.0) : 0.0;
    final color = _categoryColor(context, category.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(ExpenseCategories.label(category.category), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            Text(
              '${formatXof(category.totalAmount)} (${category.percentageOfTotal.toStringAsFixed(0)}%)',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                Container(color: theme.colorScheme.surfaceContainerHighest),
                FractionallySizedBox(widthFactor: ratio, child: Container(color: color)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _categoryColor(BuildContext context, String category) {
    final colors = context.colors;
    switch (category) {
      case 'transport': return colors.info;
      case 'food': return colors.warning;
      case 'utilities': return colors.infoText;
      case 'telecom': return AppColors.gold400;
      case 'health': return colors.error;
      case 'education': return AppColors.gold700;
      case 'shopping': return colors.errorText;
      case 'entertainment': return colors.gold;
      case 'transfers': return colors.infoText;
      case 'bills': return colors.warningText;
      case 'savings': return colors.success;
      default: return colors.textTertiary;
    }
  }
}

/// Donut chart summary widget.
class SpendingSummaryHeader extends StatelessWidget {
  final double totalSpent;
  final double totalReceived;
  final String currency;

  const SpendingSummaryHeader({super.key, required this.totalSpent, required this.totalReceived, this.currency = 'USDC'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final netFlow = totalReceived - totalSpent;
    final isPositive = netFlow >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FlowItem(label: 'Spent', amount: totalSpent, color: colors.error, currency: currency),
            Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
            _FlowItem(label: 'Received', amount: totalReceived, color: colors.success, currency: currency),
            Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
            _FlowItem(label: 'Net', amount: netFlow.abs(), color: isPositive ? colors.success : colors.error, currency: currency, prefix: isPositive ? '+' : '-'),
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

  const _FlowItem({required this.label, required this.amount, required this.color, required this.currency, this.prefix = ''});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.xs),
        Text('$prefix${formatXof(amount)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
