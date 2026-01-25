import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';
import '../../../domain/enums/index.dart';

/// Transaction Types
enum TransactionDisplayType {
  deposit,
  withdrawal,
  transferIn,
  transferOut,
  reward,
}

/// Single Transaction Row
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    this.status,
    this.icon,
    this.iconUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionDisplayType type;
  final TransactionStatus? status;
  final IconData? icon;
  final String? iconUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Icon
              _buildIcon(),
              const SizedBox(width: AppSpacing.md),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            title,
                            variant: AppTextVariant.bodyLarge,
                            color: AppColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_showStatusBadge) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _buildStatusBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      subtitle,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),

              // Amount and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    _formatAmount(),
                    variant: AppTextVariant.bodyLarge,
                    color: _getAmountColor(),
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    _formatDate(),
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _showStatusBadge =>
      status != null &&
      (status == TransactionStatus.pending ||
          status == TransactionStatus.processing ||
          status == TransactionStatus.failed);

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        backgroundColor = AppColors.warningBase.withOpacity(0.15);
        textColor = AppColors.warningText;
        label = status == TransactionStatus.pending ? 'Pending' : 'Processing';
        break;
      case TransactionStatus.failed:
        backgroundColor = AppColors.errorBase.withOpacity(0.15);
        textColor = AppColors.errorText;
        label = 'Failed';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: iconUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.network(
                iconUrl!,
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(),
              ),
            )
          : _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      icon ?? _getDefaultIcon(),
      color: _getIconColor(),
      size: 22,
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case TransactionDisplayType.deposit:
        return Icons.arrow_downward;
      case TransactionDisplayType.withdrawal:
        return Icons.arrow_upward;
      case TransactionDisplayType.transferIn:
        return Icons.call_received;
      case TransactionDisplayType.transferOut:
        return Icons.call_made;
      case TransactionDisplayType.reward:
        return Icons.card_giftcard;
    }
  }

  Color _getIconColor() {
    // Show muted color for failed transactions
    if (status == TransactionStatus.failed) {
      return AppColors.errorText;
    }

    // Show pending color for pending transactions
    if (status == TransactionStatus.pending ||
        status == TransactionStatus.processing) {
      return AppColors.warningText;
    }

    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
      case TransactionDisplayType.reward:
        return AppColors.successText;
      case TransactionDisplayType.withdrawal:
      case TransactionDisplayType.transferOut:
        return AppColors.textSecondary;
    }
  }

  Color _getAmountColor() {
    // Show muted color for failed transactions
    if (status == TransactionStatus.failed) {
      return AppColors.errorText.withOpacity(0.6);
    }

    // Show pending color for pending transactions
    if (status == TransactionStatus.pending ||
        status == TransactionStatus.processing) {
      return AppColors.warningText;
    }

    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
      case TransactionDisplayType.reward:
        return AppColors.successText;
      case TransactionDisplayType.withdrawal:
      case TransactionDisplayType.transferOut:
        return AppColors.textPrimary;
    }
  }

  String _formatAmount() {
    final sign = _isPositive() ? '+' : '-';
    final absAmount = amount.abs();
    return '$sign \$${absAmount.toStringAsFixed(2)}';
  }

  bool _isPositive() {
    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
      case TransactionDisplayType.reward:
        return true;
      case TransactionDisplayType.withdrawal:
      case TransactionDisplayType.transferOut:
        return false;
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}

/// Transaction List with header
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    this.title = 'Recent Transactions',
    this.onViewAllTap,
    this.isLoading = false,
  });

  final List<TransactionRow> transactions;
  final String title;
  final VoidCallback? onViewAllTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.gold500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.gold500,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppText(
                      title,
                      variant: AppTextVariant.cardLabel,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (onViewAllTap != null)
                  GestureDetector(
                    onTap: onViewAllTap,
                    child: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Transaction list
          if (isLoading)
            _buildLoadingState()
          else if (transactions.isEmpty)
            _buildEmptyState()
          else
            ...transactions,
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: List.generate(3, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textTertiary,
              size: 48,
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              'No transactions yet',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
