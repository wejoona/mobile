import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/utils/formatting.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BatchStatusCard extends StatelessWidget {
  final BulkBatch batch;
  final VoidCallback? onTap;

  const BatchStatusCard({
    super.key,
    required this.batch,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  batch.name,
                  variant: AppTextVariant.titleMedium,
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.payments,
                size: 16,
                color: context.colors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              AppText(
                '${batch.totalCount} payments',
                variant: AppTextVariant.bodySmall,
                color: context.colors.textSecondary,
              ),
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.attach_money,
                size: 16,
                color: context.colors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              AppText(
                Formatting.formatCurrency(batch.totalAmount),
                variant: AppTextVariant.bodySmall,
                color: context.colors.textSecondary,
              ),
            ],
          ),
          if (batch.status == BatchStatus.processing ||
              batch.status == BatchStatus.completed ||
              batch.status == BatchStatus.partiallyCompleted) ...[
            SizedBox(height: AppSpacing.sm),
            _buildProgressBar(),
          ],
          SizedBox(height: AppSpacing.sm),
          AppText(
            Formatting.formatDateTime(batch.createdAt),
            variant: AppTextVariant.bodySmall,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        statusText,
        variant: AppTextVariant.bodySmall,
        color: statusColor,
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = batch.totalCount > 0
        ? (batch.successCount + batch.failedCount) / batch.totalCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.slate,
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              '${batch.successCount} successful',
              variant: AppTextVariant.bodySmall,
              color: AppColors.successBase,
            ),
            if (batch.failedCount > 0)
              AppText(
                '${batch.failedCount} failed',
                variant: AppTextVariant.bodySmall,
                color: AppColors.errorBase,
              ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (batch.status) {
      case BatchStatus.draft:
        return AppColors.textSecondary;
      case BatchStatus.pending:
        return AppColors.warningBase;
      case BatchStatus.processing:
        return AppColors.gold500;
      case BatchStatus.completed:
        return AppColors.successBase;
      case BatchStatus.partiallyCompleted:
        return AppColors.warningBase;
      case BatchStatus.failed:
        return AppColors.errorBase;
    }
  }

  String _getStatusText() {
    switch (batch.status) {
      case BatchStatus.draft:
        return 'Draft';
      case BatchStatus.pending:
        return 'Pending';
      case BatchStatus.processing:
        return 'Processing';
      case BatchStatus.completed:
        return 'Completed';
      case BatchStatus.partiallyCompleted:
        return 'Partial';
      case BatchStatus.failed:
        return 'Failed';
    }
  }
}
