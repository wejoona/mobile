import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';
import 'rich_notification_helper.dart';
import '../../router/app_router.dart';

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

  const NotificationHandler({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<NotificationHandler> createState() => _NotificationHandlerState();
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

    // Initialize push notifications
    await pushService.initialize();

    // Set up callbacks
    pushService.onForegroundMessage = _handleForegroundMessage;
    pushService.onMessageOpenedApp = _handleMessageTap;
    pushService.onNavigate = _handleNavigation;

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
    final type = data['type'] as String?;
    final action = data['action'] as String?;
    final transactionId = data['transactionId'] as String?;
    final router = ref.read(routerProvider);

    switch (type) {
      case 'transaction':
        if (transactionId != null) {
          router.push('/transactions/$transactionId');
        } else {
          router.push('/transactions');
        }
        break;

      case 'security':
        switch (action) {
          case 'new_device_login':
            router.push('/settings/security/devices');
            break;
          case 'large_transaction':
          case 'address_whitelisted':
            router.push('/settings/security');
            break;
          default:
            router.push('/settings/security');
        }
        break;

      case 'kyc':
        switch (action) {
          case 'approved':
          case 'rejected':
          case 'pending':
            router.push('/kyc/status');
            break;
          default:
            router.push('/kyc');
        }
        break;

      case 'balance':
        router.push('/wallet');
        break;

      default:
        // Default to notifications list
        router.push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Provider for notification handler state
final notificationHandlerInitializedProvider = Provider<bool>((ref) => false);
