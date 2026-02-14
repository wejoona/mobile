import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/send/models/transfer_request.dart';

class RecentRecipientCard extends StatelessWidget {
  final RecentRecipient recipient;
  final VoidCallback onTap;

  const RecentRecipientCard({
    super.key,
    required this.recipient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: colors.gold.withValues(alpha: 0.2),
            child: AppText(
              recipient.name[0].toUpperCase(),
              variant: AppTextVariant.bodyLarge,
              color: colors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  recipient.name,
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  recipient.phoneNumber,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),

          // Last amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '\$${Formatters.formatCurrency(recipient.lastAmount)}',
                variant: AppTextVariant.bodyMedium,
                color: colors.gold,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                _formatDate(context, recipient.lastTransferDate),
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.common_today;
    } else if (difference.inDays == 1) {
      return l10n.transactions_yesterday;
    } else if (difference.inDays < 7) {
      return l10n.contacts_synced_days_ago(difference.inDays);
    } else {
      return Formatters.formatDate(date);
    }
  }
}
