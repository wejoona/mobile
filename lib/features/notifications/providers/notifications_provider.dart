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
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), () => link.close());
  ref.onDispose(() => timer.cancel());

  return repository.getUnreadCount();
});

/// Has unread notifications.
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final unreadCount = ref.watch(unreadNotificationCountProvider).value ?? 0;
  return unreadCount > 0;
});

/// Notification actions.
class NotificationActions {
  NotificationActions(this._ref, this._repository);

  final Ref _ref;
  final NotificationsRepository _repository;

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    _refreshNotificationState();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _refreshNotificationState();
  }

  void _refreshNotificationState() {
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadNotificationCountProvider);
  }
}

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref, ref.watch(notificationsRepositoryProvider));
});
