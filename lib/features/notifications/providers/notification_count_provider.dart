import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    hide unreadNotificationCountProvider;

/// Run 360: Unread notification count provider with auto-refresh
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (items) => items.where((notification) => !notification.isRead).length,
    orElse: () => 0,
  );
});

/// Provider that periodically polls for new notifications
final notificationPollingProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(minutes: 2), (_) {
    ref.invalidate(notificationsProvider);
  });
  ref.onDispose(timer.cancel);
});
