import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_provider.dart';

/// Run 360: Unread notification count provider with auto-refresh
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsNotifierProvider);
  return notificationsState.notifications
      .where((n) => !n.isRead)
      .length;
});

/// Provider that periodically polls for new notifications
final notificationPollingProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(minutes: 2), (_) {
    ref.invalidate(notificationsNotifierProvider);
  });
  ref.onDispose(timer.cancel);
});
