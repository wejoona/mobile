import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:usdc_wallet/services/notifications/push_notification_service.dart';
import 'package:usdc_wallet/services/notifications/rich_notification_helper.dart';
import 'package:usdc_wallet/router/app_router.dart';

/// Notification Handler Widget
///
/// Wraps the app and handles:
/// - Push notification initialization
/// - Foreground message display
/// - Navigation from notifications
///
/// Place this widget high in the widget tree, after authentication is complete.
class NotificationHandler extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationHandler({required this.child, super.key});

  @override
  ConsumerState<NotificationHandler> createState() =>
      _NotificationHandlerState();
}

class _NotificationHandlerState extends ConsumerState<NotificationHandler> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (_isInitialized) return;

    final pushService = ref.read(pushNotificationServiceProvider);

    // Set callbacks before initialize so terminated-state notification taps
    // are routed when Firebase returns the initial message during startup.
    pushService.onForegroundMessage = _handleForegroundMessage;
    pushService.onMessageOpenedApp = _handleMessageTap;
    pushService.onNavigate = _handleNavigation;

    // Initialize push notifications
    await pushService.initialize();

    // Register token with backend (user should be authenticated at this point)
    await pushService.registerWithBackend();

    _isInitialized = true;
  }

  /// Handle foreground message - show in-app notification
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Use RichNotificationHelper to show an in-app banner
    final richHelper = ref.read(richNotificationHelperProvider);
    richHelper.showInAppNotification(
      context,
      title: notification.title ?? 'Notification',
      body: notification.body ?? '',
      data: message.data,
      onTap: () => _handleNavigation(message.data),
    );
  }

  /// Handle message tap
  void _handleMessageTap(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  /// Handle navigation based on notification data
  void _handleNavigation(Map<String, dynamic> data) {
    final router = ref.read(routerProvider);
    router.push(routeForNotificationData(data));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Provider for notification handler state
final notificationHandlerInitializedProvider = Provider<bool>((ref) => false);

String routeForNotificationData(Map<String, dynamic> data) {
  final type = data['type'] as String?;
  final action = data['action'] as String?;
  final transactionId = data['transactionId'] as String?;

  switch (type) {
    case 'transaction':
      if (transactionId != null && transactionId.isNotEmpty) {
        return '/transactions/$transactionId';
      }
      return '/transactions';

    case 'security':
      switch (action) {
        case 'new_device_login':
          return '/settings/devices';
        case 'large_transaction':
        case 'address_whitelisted':
        default:
          return '/settings/security';
      }

    case 'kyc':
      return '/settings/kyc';

    case 'balance':
      return '/home';

    default:
      return '/notifications';
  }
}
