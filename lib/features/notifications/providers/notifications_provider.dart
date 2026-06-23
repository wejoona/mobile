import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/features/notifications/repositories/notifications_repository.dart';

/// Last notification feed successfully returned by the backend.
final lastKnownNotificationsProvider = StateProvider<List<AppNotification>>(
  (ref) => const [],
);

/// Last unread count successfully returned by the backend.
final lastKnownUnreadNotificationCountProvider = StateProvider<int>((ref) => 0);

/// Notifications list provider.
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), link.close);
  ref.onDispose(timer.cancel);

  final notifications = await repository.getNotifications(pageSize: 100);
  _writeLastKnownNotifications(ref, notifications);
  return notifications;
});

/// Unread notification count.
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), link.close);
  ref.onDispose(timer.cancel);

  final count = await repository.getUnreadCount();
  _writeLastKnownUnreadCount(ref, count);
  return count;
});

void _writeLastKnownNotifications(
  Ref ref,
  List<AppNotification> notifications,
) {
  _writeProviderStateAfterBuild(ref, () {
    ref.read(lastKnownNotificationsProvider.notifier).state = notifications;
  });
}

void _writeLastKnownUnreadCount(Ref ref, int count) {
  _writeProviderStateAfterBuild(ref, () {
    ref.read(lastKnownUnreadNotificationCountProvider.notifier).state = count;
  });
}

void _writeProviderStateAfterBuild(Ref ref, void Function() write) {
  void run() {
    if (!ref.mounted) {
      return;
    }
    write();
  }

  final scheduler = SchedulerBinding.instance;
  final phase = scheduler.schedulerPhase;
  if (phase == SchedulerPhase.idle ||
      phase == SchedulerPhase.postFrameCallbacks) {
    scheduleMicrotask(run);
  } else {
    scheduler.addPostFrameCallback((_) => run());
  }
}

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
    _markCachedNotificationAsRead(id);
    _refreshNotificationState();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _markAllCachedNotificationsAsRead();
    _refreshNotificationState();
  }

  void _markCachedNotificationAsRead(String id) {
    final notifications = _ref.read(lastKnownNotificationsProvider);
    var changed = false;
    final updated = notifications
        .map((notification) {
          if (notification.id != id || notification.isRead) {
            return notification;
          }
          changed = true;
          return notification.copyWith(isRead: true);
        })
        .toList(growable: false);
    if (!changed) {
      return;
    }
    _ref.read(lastKnownNotificationsProvider.notifier).state = updated;
    final count = _ref.read(lastKnownUnreadNotificationCountProvider);
    _ref.read(lastKnownUnreadNotificationCountProvider.notifier).state =
        count > 0 ? count - 1 : 0;
  }

  void _markAllCachedNotificationsAsRead() {
    final notifications = _ref.read(lastKnownNotificationsProvider);
    _ref.read(lastKnownNotificationsProvider.notifier).state = [
      for (final notification in notifications)
        notification.isRead
            ? notification
            : notification.copyWith(isRead: true),
    ];
    _ref.read(lastKnownUnreadNotificationCountProvider.notifier).state = 0;
  }

  void _refreshNotificationState() {
    _ref
      ..invalidate(notificationsProvider)
      ..invalidate(unreadNotificationCountProvider);
  }
}

final notificationActionsProvider = Provider<NotificationActions>(
  (ref) => NotificationActions(ref, ref.watch(notificationsRepositoryProvider)),
);
