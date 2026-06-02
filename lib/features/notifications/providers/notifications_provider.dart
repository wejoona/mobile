import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Notifications list provider — wired to Dio (mock interceptor handles fallback).
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 1), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get('/notifications');
  final raw = response.data;
  final List items;
  if (raw is Map<String, dynamic>) {
    items =
        raw['notifications'] as List? ??
        raw['data'] as List? ??
        raw['items'] as List? ??
        [];
  } else if (raw is List) {
    items = raw;
  } else {
    items = [];
  }
  return items
      .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
      .toList();
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

/// Notification actions — wired to Dio.
class NotificationActions {
  final dynamic _dio;
  NotificationActions(this._dio);

  Future<void> markAsRead(String id) async {
    // ignore: avoid_dynamic_calls
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    // ignore: avoid_dynamic_calls
    await _dio.put('/notifications/read-all');
  }

  Future<void> delete(String id) async {
    // ignore: avoid_dynamic_calls
    await _dio.delete('/notifications/$id');
  }
}

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref.watch(dioProvider));
});
