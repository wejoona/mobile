/// Alert Card Widget
/// Displays a single transaction alert
library;

import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/index.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    this.onDismiss,
    this.showActions = true,
  });

  final TransactionAlert alert;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.alertId),
      direction: onDismiss != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: alert.isRead ? AppColors.slate : AppColors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _getBorderColor(),
              width: alert.severity == AlertSeverity.critical ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: AppText(
                                  alert.title,
                                  variant: AppTextVariant.bodyLarge,
                                  color: alert.isRead
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (alert.isActionRequired) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorBase,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: const AppText(
                                    'Action Required',
                                    variant: AppTextVariant.labelSmall,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: alert.severity.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      alert.message,
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (alert.amount != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          AppText(
                            '${alert.amount?.toStringAsFixed(2)} ${alert.currency ?? 'USD'}',
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildSeverityBadge(),
                            const SizedBox(width: AppSpacing.sm),
                            AppText(
                              _formatTime(alert.createdAt),
                              variant: AppTextVariant.bodySmall,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                        if (showActions && alert.actionTaken != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successBase.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: AppText(
                              alert.actionTaken!.displayName,
                              variant: AppTextVariant.labelSmall,
                              color: AppColors.successBase,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: alert.alertType.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        alert.alertType.icon,
        color: alert.alertType.color,
        size: 24,
      ),
    );
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: alert.severity.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        alert.severity.displayName,
        variant: AppTextVariant.labelSmall,
        color: alert.severity.color,
      ),
    );
  }

  Color _getBorderColor() {
    if (!alert.isRead && alert.severity == AlertSeverity.critical) {
      return alert.severity.color.withValues(alpha: 0.5);
    }
    if (!alert.isRead) {
      return AppColors.gold500.withValues(alpha: 0.3);
    }
    return AppColors.borderSubtle;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
