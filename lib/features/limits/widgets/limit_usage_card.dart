import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';

/// Card showing transaction limit usage.
class LimitUsageCard extends StatelessWidget {
  final TransactionLimits limits;

  const LimitUsageCard({super.key, required this.limits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction Limits', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _LimitRow(label: 'Daily', used: limits.dailyUsed, limit: limits.dailyLimit, currency: limits.currency),
            const SizedBox(height: 12),
            _LimitRow(label: 'Weekly', used: limits.weeklyUsed, limit: limits.weeklyLimit, currency: limits.currency),
            const SizedBox(height: 12),
            _LimitRow(label: 'Monthly', used: limits.monthlyUsed, limit: limits.monthlyLimit, currency: limits.currency),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Max per transaction', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text('\$${limits.singleTransactionMax.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final double used;
  final double limit;
  final String currency;

  const _LimitRow({required this.label, required this.used, required this.limit, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usage = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final color = usage > 0.9 ? Colors.red : (usage > 0.7 ? Colors.orange : theme.colorScheme.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            Text('\$${used.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 4),
        ProgressBar(value: usage, height: 6, color: color),
      ],
    );
  }
}
