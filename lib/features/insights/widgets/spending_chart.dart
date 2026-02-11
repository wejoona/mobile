import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/utils/color_utils.dart';

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
          const SizedBox(height: 12),
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
    final color = _categoryColor(category.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(ExpenseCategories.label(category.category), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            Text(
              '\$${category.totalAmount.toStringAsFixed(2)} (${category.percentageOfTotal.toStringAsFixed(0)}%)',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

  Color _categoryColor(String category) {
    switch (category) {
      case 'transport': return Colors.blue;
      case 'food': return Colors.orange;
      case 'utilities': return Colors.teal;
      case 'telecom': return Colors.purple;
      case 'health': return Colors.red;
      case 'education': return Colors.indigo;
      case 'shopping': return Colors.pink;
      case 'entertainment': return Colors.amber;
      case 'transfers': return Colors.cyan;
      case 'bills': return Colors.brown;
      case 'savings': return Colors.green;
      default: return Colors.grey;
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
    final netFlow = totalReceived - totalSpent;
    final isPositive = netFlow >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FlowItem(label: 'Spent', amount: totalSpent, color: Colors.red, currency: currency),
            Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
            _FlowItem(label: 'Received', amount: totalReceived, color: Colors.green, currency: currency),
            Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
            _FlowItem(label: 'Net', amount: netFlow.abs(), color: isPositive ? Colors.green : Colors.red, currency: currency, prefix: isPositive ? '+' : '-'),
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
        const SizedBox(height: 4),
        Text('$prefix\$${amount.toStringAsFixed(2)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
