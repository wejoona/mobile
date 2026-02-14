import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Notification Navigation Handler
///
/// Handles deep linking and navigation based on notification data.
/// This is used when user taps on a notification.
class NotificationNavigationHandler {
  final GoRouter router;
  static final _logger = AppLogger('NotificationNavigation');

  NotificationNavigationHandler(this.router);

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
      router.push(route);
      return;
    }

    // Handle by notification type
    switch (type) {
      case 'transaction':
      case 'transactionComplete':
      case 'transactionFailed':
        if (transactionId != null) {
          router.push('/transactions/$transactionId');
        } else {
          router.push('/transactions');
        }
        break;

      case 'security':
      case 'securityAlert':
      case 'newDeviceLogin':
        router.push('/settings/security');
        break;

      case 'deposit':
      case 'depositComplete':
        router.push('/home');
        break;

      case 'withdrawal':
      case 'withdrawalPending':
        if (transactionId != null) {
          router.push('/transactions/$transactionId');
        } else {
          router.push('/transactions');
        }
        break;

      case 'kyc':
      case 'kycApproved':
      case 'kycRejected':
        router.push('/settings/kyc');
        break;

      case 'promotion':
      case 'referral':
        router.push('/referrals');
        break;

      case 'lowBalance':
        router.push('/deposit');
        break;

      case 'largeTransaction':
      case 'unusualLocation':
      case 'rapidTransactions':
      case 'suspiciousPattern':
      case 'failedAttempts':
        router.push('/settings/security');
        break;

      case 'priceAlert':
      case 'weeklySpendingSummary':
        router.push('/home');
        break;

      default:
        // Default to notifications list
        router.push('/notifications');
        break;
    }
  }

  /// Handle navigation from notification data map
  void handleDataNavigation(Map<String, dynamic> data) {
    final message = RemoteMessage(data: data);
    handleNotificationNavigation(message);
  }
}
