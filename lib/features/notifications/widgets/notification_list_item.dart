import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/utils/formatters.dart';

/// A single notification list item.
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      onTap: onTap,
      minVerticalPadding: AppSpacing.md,
      tileColor: notification.isRead
          ? null
          : colors.gold.withValues(alpha: 0.05),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.gold.withValues(alpha: colors.isDark ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.gold.withValues(alpha: 0.18)),
        ),
        child: Icon(
          _getIcon(notification.type.name),
          color: colors.gold,
          size: 20,
        ),
      ),
      title: AppText(
        notification.title,
        variant: AppTextVariant.bodyLarge,
        color: colors.textPrimary,
        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: AppText(
        notification.body,
        variant: AppTextVariant.bodySmall,
        color: colors.textSecondary,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AppText(
        formatRelativeTime(notification.createdAt),
        variant: AppTextVariant.labelSmall,
        color: colors.textTertiary,
        textAlign: TextAlign.end,
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'transfer':
        return Icons.swap_horiz;
      case 'deposit':
        return Icons.arrow_downward;
      case 'security':
        return Icons.shield_outlined;
      case 'promotion':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
