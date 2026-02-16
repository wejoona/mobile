import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/features/notifications/widgets/notification_tile.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';

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
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(5, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const ShimmerLoading.circle(size: 40),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerLoading(width: 180, height: 14),
                      SizedBox(height: 6),
                      ShimmerLoading(width: 120, height: 12),
                    ],
                  )),
                ],
              ),
            )),
          ),
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Aucune notification',
              subtitle: 'Vous êtes à jour !',
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
