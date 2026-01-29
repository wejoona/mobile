import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../providers/insights_provider.dart';

class TopRecipientsSection extends ConsumerWidget {
  const TopRecipientsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipients = ref.watch(topRecipientsProvider);

    if (recipients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insights_top_recipients,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recipients list
          ...recipients.asMap().entries.map((entry) {
            final index = entry.key;
            final recipient = entry.value;

            return Column(
              children: [
                if (index > 0) const SizedBox(height: AppSpacing.md),
                _buildRecipientRow(context, recipient, index + 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecipientRow(
    BuildContext context,
    dynamic recipient,
    int rank,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.gold500.withValues(alpha: 0.2) : AppColors.slate,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTypography.bodyMedium.copyWith(
                  color: rank <= 3 ? AppColors.gold500 : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.gold500.withValues(alpha: 0.2),
            child: Text(
              recipient.name[0].toUpperCase(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${recipient.transactionCount} transactions',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${recipient.totalSent.toStringAsFixed(2)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${recipient.percentage.toStringAsFixed(1)}%',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.sm),

          // Quick send button
          IconButton(
            icon: const Icon(Icons.send, size: 18),
            color: AppColors.gold500,
            onPressed: () {
              // Navigate to send screen with pre-filled recipient
              context.push('/send');
            },
          ),
        ],
      ),
    );
  }
}
