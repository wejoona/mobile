import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Card displaying a bulk payment batch status.
class BulkPaymentCard extends StatelessWidget {
  final BulkBatch payment;
  final VoidCallback? onTap;

  const BulkPaymentCard({super.key, required this.payment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pendingCount =
        payment.totalCount - payment.successCount - payment.failedCount;
    final progress = payment.totalCount > 0
        ? (payment.successCount + payment.failedCount) / payment.totalCount
        : 0.0;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(
                    alpha: colors.isDark ? 0.16 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(Icons.groups_rounded, color: colors.gold, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      payment.name,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppText(
                      '${payment.totalCount} destinataires • ${formatXof(payment.totalAmount)}',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ProgressBar(value: progress, height: 4),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusChip(
                count: payment.successCount,
                label: 'Réussi',
                tone: StatusTone.success,
              ),
              _StatusChip(
                count: payment.failedCount,
                label: 'Échoué',
                tone: StatusTone.danger,
              ),
              _StatusChip(
                count: pendingCount,
                label: 'En attente',
                tone: StatusTone.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final StatusTone tone;

  const _StatusChip({
    required this.count,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: '$count $label', tone: tone, compact: true);
  }
}
