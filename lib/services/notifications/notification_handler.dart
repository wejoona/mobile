import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/services/notifications/notification_route_intent.dart';
import 'package:usdc_wallet/services/notifications/push_notification_service.dart';
import 'package:usdc_wallet/services/notifications/rich_notification_helper.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';

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
    final data = message.data;
    final title = notification?.title ?? _titleForDataMessage(data);
    final body = notification?.body ?? _bodyForDataMessage(data);

    _refreshStateForNotification(data);

    if (title == null && body == null) {
      return;
    }

    // Use RichNotificationHelper to show an in-app banner
    ref
        .read(richNotificationHelperProvider)
        .showInAppNotification(
          context,
          title: title ?? 'Korido',
          body: body ?? '',
          data: data,
          onTap: () => _handleNavigation(data),
        );
  }

  /// Handle message tap
  void _handleMessageTap(RemoteMessage message) {
    _refreshStateForNotification(message.data);
    _handleNavigation(message.data);
  }

  /// Handle navigation based on notification data
  void _handleNavigation(Map<String, dynamic> data) {
    unawaited(context.fsmPush(routeForNotificationData(data)));
  }

  void _refreshStateForNotification(Map<String, dynamic> data) {
    ref
      ..invalidate(notificationsProvider)
      ..invalidate(unreadNotificationCountProvider);

    if (!_isKycNotification(data)) {
      return;
    }

    ref.invalidate(kycProfileProvider);
    unawaited(ref.read(kycProvider.notifier).loadVerificationStatus());
    unawaited(ref.read(kycStateMachineProvider.notifier).fetch());
  }

  bool _isKycNotification(Map<String, dynamic> data) {
    final intent = NotificationRouteIntent.fromData(data);
    if (intent.kind == NotificationRouteIntentKind.kyc) {
      return true;
    }
    final actionUrl = data['actionUrl']?.toString().trim();
    if (actionUrl == '/kyc' ||
        (actionUrl != null && actionUrl.startsWith('/kyc?'))) {
      return true;
    }

    final values = [
      data['type'],
      data['category'],
      data['action'],
      data['event'],
      data['eventType'],
      data['referenceType'],
      data['status'],
    ].map(_normalized);

    return values.any(
      (value) =>
          value == 'kyc' ||
          value == 'kyc_status_updated' ||
          value == 'kyc.status_updated' ||
          value == 'kyc_approved' ||
          value == 'kyc.approved',
    );
  }

  String? _titleForDataMessage(Map<String, dynamic> data) {
    final explicit = _firstText(data['title'], data['notificationTitle']);
    if (explicit != null) {
      return explicit;
    }
    if (_isKycNotification(data)) {
      final status = _normalized(data['status'] ?? data['kycStatus']);
      return switch (status) {
        'approved' || 'verified' || 'auto_approved' => 'Verification approved',
        'rejected' => 'Verification needs attention',
        'manual_review' ||
        'submitted' ||
        'pending_verification' => 'Verification under review',
        _ => 'Verification updated',
      };
    }
    return _firstText(data['subject']);
  }

  String? _bodyForDataMessage(Map<String, dynamic> data) {
    final explicit = _firstText(
      data['body'],
      data['message'],
      data['notificationBody'],
    );
    if (explicit != null) {
      return explicit;
    }
    if (_isKycNotification(data)) {
      final status = _normalized(data['status'] ?? data['kycStatus']);
      return switch (status) {
        'approved' || 'verified' || 'auto_approved' =>
          'Your Korido limits and verification status have been refreshed.',
        'rejected' => 'Open Korido to review what needs to be corrected.',
        'manual_review' || 'submitted' || 'pending_verification' =>
          'A Korido reviewer is checking your information.',
        _ => 'Open Korido to see the latest status.',
      };
    }
    return null;
  }

  String? _firstText(Object? first, [Object? second, Object? third]) {
    for (final candidate in [first, second, third]) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String _normalized(Object? value) =>
      value?.toString().trim().toLowerCase().replaceAll('-', '_') ?? '';

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
