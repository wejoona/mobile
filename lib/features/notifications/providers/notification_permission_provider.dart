import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notifications;
import 'package:usdc_wallet/services/notifications/push_notification_service.dart';

/// Notification Permission State
class NotificationPermissionState {
  final bool isEnabled;
  final bool isLoading;
  final String? error;

  const NotificationPermissionState({
    this.isEnabled = false,
    this.isLoading = false,
    this.error,
  });

  NotificationPermissionState copyWith({
    bool? isEnabled,
    bool? isLoading,
    String? error,
  }) {
    return NotificationPermissionState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notification Permission Notifier
class NotificationPermissionNotifier
    extends Notifier<NotificationPermissionState> {
  @override
  NotificationPermissionState build() {
    _checkPermissionStatus();
    return const NotificationPermissionState();
  }

  Future<void> _checkPermissionStatus() async {
    final pushService = ref.read(pushNotificationServiceProvider);
    final isEnabled = await pushService.isEnabled;
    state = state.copyWith(isEnabled: isEnabled);
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pushService = ref.read(pushNotificationServiceProvider);

      // Initialize push notifications (will request permission)
      await pushService.initialize();

      // Check if permission was granted
      final isEnabled = await pushService.isEnabled;

      if (isEnabled) {
        final registered = await pushService.registerWithBackend();
        if (!registered) {
          state = state.copyWith(
            isEnabled: false,
            isLoading: false,
            error: 'notifications_backend_registration_failed',
          );
          return false;
        }
      }

      state = state.copyWith(isEnabled: isEnabled, isLoading: false);
      return isEnabled;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Refresh permission status
  Future<void> refresh() async {
    await _checkPermissionStatus();
  }
}

/// Notification Permission Provider
final notificationPermissionProvider =
    NotifierProvider<
      NotificationPermissionNotifier,
      NotificationPermissionState
    >(NotificationPermissionNotifier.new);

/// Simple provider to check if notifications are enabled
final isNotificationEnabledProvider = FutureProvider<bool>((ref) async {
  final pushService = ref.watch(pushNotificationServiceProvider);
  return await pushService.isEnabled;
});

/// Provider for unread notification count
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notifications.unreadNotificationCountProvider.future);
});
