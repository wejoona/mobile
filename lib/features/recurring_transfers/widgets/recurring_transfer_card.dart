import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer_status.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Card showing a recurring transfer summary.
class RecurringTransferCard extends StatelessWidget {
  final RecurringTransfer transfer;
  final VoidCallback? onTap;

  const RecurringTransferCard({super.key, required this.transfer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).languageCode;

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          UserAvatar(
            firstName: transfer.recipientName.split(' ').first,
            lastName: transfer.recipientName.split(' ').length > 1
                ? transfer.recipientName.split(' ').last
                : null,
            size: 44,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  transfer.recipientName,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  transfer.frequency.getDisplayName(locale),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.xs),
                StatusPill(
                  label: transfer.status.getDisplayName(locale),
                  tone: _statusTone,
                  compact: true,
                  emphasis: transfer.isActive,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountText.fromText(
                formatCurrency(transfer.amount, transfer.currency),
                size: AmountTextSize.medium,
                color: colors.textPrimary,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppText(
                '${transfer.executedCount} sent',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  StatusTone get _statusTone {
    switch (transfer.status) {
      case RecurringTransferStatus.active:
        return StatusTone.success;
      case RecurringTransferStatus.paused:
        return StatusTone.warning;
      case RecurringTransferStatus.completed:
        return StatusTone.info;
      case RecurringTransferStatus.cancelled:
        return StatusTone.neutral;
    }
  }
}
