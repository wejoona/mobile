import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:usdc_wallet/utils/logger.dart';

typedef NotificationRoutePusher = void Function(String route);

/// Notification Navigation Handler
///
/// Handles deep linking and navigation based on notification data.
/// This is used when user taps on a notification.
class NotificationNavigationHandler {
  final NotificationRoutePusher pushRoute;
  static final _logger = AppLogger('NotificationNavigation');

  NotificationNavigationHandler(this.pushRoute);

  /// Handle navigation from notification message
  void handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final transactionId = data['transactionId'] as String?;
    final route = data['route'] as String?;

    _logger.debug('Handling notification navigation', {
      'type': type,
      'transactionId': transactionId,
      'route': route,
    });

    // Custom route takes precedence
    if (route != null && route.isNotEmpty) {
      pushRoute(route);
      return;
    }

    // Handle by notification type
    switch (type) {
      case 'transaction':
      case 'transactionComplete':
      case 'transactionFailed':
        if (transactionId != null) {
          pushRoute('/transactions/$transactionId');
        } else {
          pushRoute('/transactions');
        }
        break;

      case 'security':
      case 'securityAlert':
      case 'newDeviceLogin':
        pushRoute('/settings/security');
        break;

      case 'deposit':
      case 'depositComplete':
        pushRoute('/home');
        break;

      case 'withdrawal':
      case 'withdrawalPending':
        if (transactionId != null) {
          pushRoute('/transactions/$transactionId');
        } else {
          pushRoute('/transactions');
        }
        break;

      case 'kyc':
      case 'kycApproved':
      case 'kycRejected':
        pushRoute('/settings/kyc');
        break;

      case 'promotion':
      case 'referral':
        pushRoute('/referrals');
        break;

      case 'lowBalance':
        pushRoute('/deposit');
        break;

      case 'largeTransaction':
      case 'unusualLocation':
      case 'rapidTransactions':
      case 'suspiciousPattern':
      case 'failedAttempts':
        pushRoute('/settings/security');
        break;

      case 'priceAlert':
      case 'weeklySpendingSummary':
        pushRoute('/home');
        break;

      default:
        // Default to notifications list
        pushRoute('/notifications');
        break;
    }
  }

  /// Handle navigation from notification data map
  void handleDataNavigation(Map<String, dynamic> data) {
    final message = RemoteMessage(data: data);
    handleNotificationNavigation(message);
  }
}
