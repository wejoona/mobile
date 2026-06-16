import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notifications;

/// Run 360: Unread notification count provider with auto-refresh
final unreadNotificationCountProvider = Provider<int>((ref) {
  final unreadCount = ref.watch(notifications.unreadNotificationCountProvider);
  final lastKnown = ref.watch(
    notifications.lastKnownUnreadNotificationCountProvider,
  );
  return unreadCount.hasValue ? unreadCount.value ?? lastKnown : lastKnown;
});

/// Provider that periodically polls for new notifications
final notificationPollingProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(minutes: 2), (_) {
    ref
      ..invalidate(notifications.notificationsProvider)
      ..invalidate(notifications.unreadNotificationCountProvider);
  });
  ref.onDispose(timer.cancel);
});
