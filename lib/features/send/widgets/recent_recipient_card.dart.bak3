import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/formatters.dart';
import '../models/transfer_request.dart';

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
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppColors.gold500.withOpacity(0.2),
            child: AppText(
              recipient.name[0].toUpperCase(),
              variant: AppTextVariant.bodyLarge,
                color: AppColors.gold500,
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
                    color: AppColors.textSecondary,
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
                  color: AppColors.gold500,
                  fontWeight: FontWeight.w600,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                _formatDate(recipient.lastTransferDate),
                variant: AppTextVariant.bodySmall,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return Formatters.formatDate(date);
    }
  }
}
