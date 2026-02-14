import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/features/notifications/widgets/notification_tile.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';

/// Notifications list screen.
class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () async {
                final actions = ref.read(notificationActionsProvider);
                await actions.markAllAsRead();
                ref.invalidate(notificationsProvider);
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(height: 0.5, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
              itemBuilder: (_, i) {
                final notification = notifications[i];
                return NotificationTile(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      final actions = ref.read(notificationActionsProvider);
                      await actions.markAsRead(notification.id);
                      ref.invalidate(notificationsProvider);
                    }
                  },
                  onDismiss: () async {
                    final actions = ref.read(notificationActionsProvider);
                    await actions.delete(notification.id);
                    ref.invalidate(notificationsProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
