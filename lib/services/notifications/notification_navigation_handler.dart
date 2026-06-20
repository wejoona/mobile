import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:usdc_wallet/services/notifications/notification_route_intent.dart';
import 'package:usdc_wallet/utils/logger.dart';

typedef NotificationRoutePusher = void Function(String route);

/// Notification Navigation Handler
///
/// Handles deep linking and navigation based on notification data.
/// This is used when user taps on a notification.
class NotificationNavigationHandler {
  NotificationNavigationHandler(this.pushRoute);

  final NotificationRoutePusher pushRoute;
  static const _logger = AppLogger('NotificationNavigation');

  /// Handle navigation from notification message
  void handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final transactionId = data['transactionId'] as String?;
    final route = routeForNotificationData(data);

    _logger.debug('Handling notification navigation', {
      'type': type,
      'transactionId': transactionId,
      'route': route,
    });

    pushRoute(route);
  }

  /// Handle navigation from notification data map
  void handleDataNavigation(Map<String, dynamic> data) {
    final message = RemoteMessage(data: data);
    handleNotificationNavigation(message);
  }
}
