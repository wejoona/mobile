import 'package:flutter/material.dart';
import '../../../domain/entities/notification.dart';
import '../../../utils/duration_extensions.dart';

/// Notification list tile.
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({super.key, required this.notification, this.onTap, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread ? theme.colorScheme.primaryContainer.withOpacity(0.1) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeIcon(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.createdAt.timeAgo,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeIcon(ThemeData theme) {
    IconData icon;
    Color color;
    switch (notification.type) {
      case NotificationType.transaction:
        icon = Icons.swap_horiz_rounded;
        color = Colors.blue;
      case NotificationType.security:
        icon = Icons.shield_rounded;
        color = Colors.red;
      case NotificationType.kyc:
        icon = Icons.verified_user_rounded;
        color = Colors.orange;
      case NotificationType.promotion:
        icon = Icons.local_offer_rounded;
        color = Colors.purple;
      case NotificationType.system:
        icon = Icons.settings_rounded;
        color = Colors.grey;
      case NotificationType.general:
        icon = Icons.notifications_rounded;
        color = theme.colorScheme.primary;
    }
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
