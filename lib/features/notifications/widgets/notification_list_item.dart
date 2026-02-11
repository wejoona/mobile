import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../domain/entities/notification.dart';
import '../../../utils/formatters.dart';

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
      tileColor: notification.isRead
          ? null
          : colors.primary.withValues(alpha: 0.04),
      leading: CircleAvatar(
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        child: Icon(
          _getIcon(notification.type),
          color: colors.primary,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        notification.body,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formatRelativeTime(notification.createdAt),
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
        ),
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
