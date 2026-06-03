import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/features/notifications/repositories/notifications_repository.dart';

/// Notifications list provider.
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), () => link.close());
  ref.onDispose(() => timer.cancel());

  return repository.getNotifications();
});

/// Unread notification count.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});

/// Has unread notifications.
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadNotificationCountProvider) > 0;
});

/// Notification actions.
class NotificationActions {
  NotificationActions(this._repository);

  final NotificationsRepository _repository;

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
  }
}

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref.watch(notificationsRepositoryProvider));
});
