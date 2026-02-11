import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/notification.dart';
import '../../../services/api/api_client.dart';

/// Notifications list provider.
final notificationsProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 1), () => link.close());

  final response = await dio.get('/notifications');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Unread notification count.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

/// Has unread notifications.
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadNotificationCountProvider) > 0;
});

/// Notification actions.
class NotificationActions {
  final Dio _dio;

  NotificationActions(this._dio);

  Future<void> markAsRead(String notificationId) async {
    await _dio.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/notifications/read-all');
  }

  Future<void> delete(String notificationId) async {
    await _dio.delete('/notifications/$notificationId');
  }
}

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref.watch(dioProvider));
});
