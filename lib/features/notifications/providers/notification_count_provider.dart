import 'package:usdc_wallet/providers/missing_providers.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Run 360: Unread notification count provider with auto-refresh
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsNotifierProvider);
  return ((notificationsState.value ?? []) as List)
      
      .length;
});

/// Provider that periodically polls for new notifications
final notificationPollingProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(minutes: 2), (_) {
    ref.invalidate(notificationsNotifierProvider);
  });
  ref.onDispose(timer.cancel);
});
