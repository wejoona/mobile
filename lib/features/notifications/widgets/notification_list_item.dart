import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/features/notifications/widgets/notification_tile.dart';

/// Backward-compatible notification row wrapper.
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    required this.notification,
    super.key,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      NotificationTile(notification: notification, onTap: onTap);
}
