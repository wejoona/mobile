import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Card displaying a bulk payment batch status.
class BulkPaymentCard extends StatelessWidget {
  final BulkBatch payment;
  final VoidCallback? onTap;

  const BulkPaymentCard({super.key, required this.payment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingCount = payment.totalCount - payment.successCount - payment.failedCount;
    final progress = payment.totalCount > 0
        ? (payment.successCount + payment.failedCount) / payment.totalCount
        : 0.0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.groups_rounded, color: theme.colorScheme.onTertiaryContainer, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(payment.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        Text('${payment.totalCount} destinataires • ${formatXof(payment.totalAmount)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressBar(value: progress, height: 4),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusChip(count: payment.successCount, label: 'Réussi', color: Colors.green),
                  _StatusChip(count: payment.failedCount, label: 'Échoué', color: Colors.red),
                  _StatusChip(count: pendingCount, label: 'En attente', color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusChip({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$count $label', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
