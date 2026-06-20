import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/notifications/notification_route_intent.dart';
import 'package:usdc_wallet/services/notifications/push_notification_service.dart';
import 'package:usdc_wallet/services/notifications/rich_notification_helper.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

export 'package:usdc_wallet/services/notifications/notification_route_intent.dart'
    show routeForNotificationData;

/// Notification Handler Widget
///
/// Wraps the app and handles:
/// - Push notification initialization
/// - Foreground message display
/// - Navigation from notifications
///
/// Place this widget high in the widget tree, after authentication is complete.
class NotificationHandler extends ConsumerStatefulWidget {
  const NotificationHandler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationHandler> createState() =>
      _NotificationHandlerState();
}

class _NotificationHandlerState extends ConsumerState<NotificationHandler> {
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<void> _initializeNotifications() async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;

    // Set callbacks before initialize so terminated-state notification taps
    // are routed when Firebase returns the initial message during startup.
    final pushService = ref.read(pushNotificationServiceProvider)
      ..onForegroundMessage = _handleForegroundMessage
      ..onMessageOpenedApp = _handleMessageTap
      ..onNavigate = _handleNavigation;

    try {
      // Initialize push notifications without triggering an OS prompt.
      await pushService.initialize();

      // Register token with backend only after auth is known.
      await pushService.registerWithBackend();

      _isInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  /// Handle foreground message - show in-app notification
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    // Use RichNotificationHelper to show an in-app banner
    ref
        .read(richNotificationHelperProvider)
        .showInAppNotification(
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
    unawaited(context.fsmPush(routeForNotificationData(data)));
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.isAuthenticated),
    );

    if (isAuthenticated && !_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_initializeNotifications());
        }
      });
    }

    return widget.child;
  }
}

/// Provider for notification handler state
final notificationHandlerInitializedProvider = Provider<bool>((ref) => false);
