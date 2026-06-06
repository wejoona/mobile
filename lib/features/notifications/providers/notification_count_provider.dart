import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notifications;

/// Run 360: Unread notification count provider with auto-refresh
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notifications.unreadNotificationCountProvider).value ?? 0;
});

/// Provider that periodically polls for new notifications
final notificationPollingProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(minutes: 2), (_) {
    ref.invalidate(notifications.notificationsProvider);
    ref.invalidate(notifications.unreadNotificationCountProvider);
  });
  ref.onDispose(timer.cancel);
});
