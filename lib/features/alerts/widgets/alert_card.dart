/// Alert Card Widget
/// Displays a single transaction alert
library;

import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/alerts/models/index.dart';

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
    final colors = context.colors;
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
          color: context.colors.error,
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
            color: alert.isRead ? colors.container : colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _getBorderColor(colors),
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
                                      ? colors.textSecondary
                                      : colors.textPrimary,
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
                                    color: context.colors.error,
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
                      color: colors.textSecondary,
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
                            color: colors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          AppText(
                            '${alert.amount?.toStringAsFixed(2)} ${alert.currency ?? 'USD'}',
                            variant: AppTextVariant.bodySmall,
                            color: colors.textTertiary,
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
                              color: colors.textTertiary,
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
                              color: context.colors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: AppText(
                              alert.actionTaken!.displayName,
                              variant: AppTextVariant.labelSmall,
                              color: context.colors.success,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  Icons.chevron_right,
                  color: colors.textTertiary,
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

  Color _getBorderColor(ThemeColors colors) {
    if (!alert.isRead && alert.severity == AlertSeverity.critical) {
      return alert.severity.color.withValues(alpha: 0.5);
    }
    if (!alert.isRead) {
      return colors.gold.withValues(alpha: 0.3);
    }
    return colors.borderSubtle;
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
