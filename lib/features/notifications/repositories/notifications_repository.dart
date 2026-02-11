import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';

/// Repository for notification operations.
class NotificationsRepository {
  final NotificationsService _service;

  NotificationsRepository(this._service);

  /// Get all notifications.
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _service.getNotifications();
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id) async {
    return _service.markAsRead(id);
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    return _service.markAllAsRead();
  }

  /// Get unread notification count.
  Future<int> getUnreadCount() async {
    return _service.getUnreadCount();
  }
}

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  final service = ref.watch(notificationsServiceProvider);
  return NotificationsRepository(service);
});
