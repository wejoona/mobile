import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/recurring_transfer.dart';
import '../models/recurring_transfer_status.dart';
import '../models/transfer_frequency.dart';

class RecurringTransferCard extends StatelessWidget {
  const RecurringTransferCard({
    super.key,
    required this.transfer,
    this.onTap,
  });

  final RecurringTransfer transfer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: transfer.isActive
            ? AppCardVariant.elevated
            : AppCardVariant.subtle,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          transfer.recipientName,
                          variant: AppTextVariant.headlineSmall,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AppText(
                          transfer.recipientPhone,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(l10n, transfer.status),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.recurringTransfers_amount,
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        '${transfer.amount.toStringAsFixed(0)} ${transfer.currency}',
                        variant: AppTextVariant.headlineSmall,
                        color: AppColors.gold500,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        l10n.recurringTransfers_frequency,
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        transfer.frequency.getDisplayName(
                          Localizations.localeOf(context).toString(),
                        ),
                        variant: AppTextVariant.bodyMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.obsidian.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.gold500,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppText(
                        transfer.getFrequencyDescription(
                          Localizations.localeOf(context).toString(),
                        ),
                        variant: AppTextVariant.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (transfer.isActive) ...[
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    AppText(
                      '${l10n.recurringTransfers_nextExecution}: ${_formatDate(transfer.nextExecutionDate)}',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
              if (transfer.note != null) ...[
                SizedBox(height: AppSpacing.sm),
                AppText(
                  transfer.note!,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n, RecurringTransferStatus status) {
    Color color;
    switch (status) {
      case RecurringTransferStatus.active:
        color = AppColors.successBase;
        break;
      case RecurringTransferStatus.paused:
        color = AppColors.warningBase;
        break;
      case RecurringTransferStatus.completed:
        color = AppColors.textSecondary;
        break;
      case RecurringTransferStatus.cancelled:
        color = AppColors.errorBase;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color, width: 1),
      ),
      child: Builder(
        builder: (context) => AppText(
          status.getDisplayName(Localizations.localeOf(context).toString()),
          variant: AppTextVariant.bodySmall,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return 'In $diff days';

    return '${date.day}/${date.month}/${date.year}';
  }
}
