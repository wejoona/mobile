import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';

/// Mock data for notifications
class NotificationsMockState {
  static Map<String, dynamic> preferences = _defaultPreferences();

  static void reset() {
    preferences = _defaultPreferences();
  }

  static Map<String, dynamic> _defaultPreferences() {
    final now = DateTime.now().toIso8601String();
    return {
      'id': 'notif_pref_001',
      'userId': 'user-123',
      'pushEnabled': true,
      'pushTransactions': true,
      'pushSecurity': true,
      'pushMarketing': false,
      'emailEnabled': true,
      'emailTransactions': true,
      'emailMonthlyStatement': true,
      'emailMarketing': false,
      'smsEnabled': true,
      'smsTransactions': true,
      'smsSecurity': true,
      'largeTransactionThreshold': 1000.0,
      'lowBalanceThreshold': 100.0,
      'createdAt': now,
      'updatedAt': now,
    };
  }
}

class NotificationsMock {
  static void register(MockInterceptor interceptor) {
    // GET /notifications - Get all notifications
    interceptor.register(
      method: 'GET',
      path: '/notifications',
      handler: _handleGetAll,
    );

    for (final path in const [
      '/notifications/unread-count',
      '/notifications/unread/count',
    ]) {
      interceptor.register(
        method: 'GET',
        path: path,
        handler: _handleGetUnreadCount,
      );
    }

    for (final path in const [
      '/user/notification-preferences',
      '/notifications/preferences',
    ]) {
      interceptor.register(
        method: 'GET',
        path: path,
        handler: _handleGetPreferences,
      );
      interceptor.register(
        method: 'PUT',
        path: path,
        handler: _handleUpdatePreferences,
      );
    }

    // PUT /notifications/:id/read - Mark notification as read
    interceptor.register(
      method: 'PUT',
      path: '/notifications/:id/read',
      handler: _handleMarkAsRead,
    );

    // PUT /notifications/read-all - Mark all as read
    interceptor.register(
      method: 'PUT',
      path: '/notifications/read-all',
      handler: _handleMarkAllAsRead,
    );

    // POST /notifications/push/token - Register FCM token
    interceptor.register(
      method: 'POST',
      path: '/notifications/push/token',
      handler: _handleRegisterToken,
    );

    // DELETE /notifications/push/token - Remove FCM token
    interceptor.register(
      method: 'DELETE',
      path: '/notifications/push/token',
      handler: _handleRemoveToken,
    );

    // DELETE /notifications/push/tokens - Remove all FCM tokens
    interceptor.register(
      method: 'DELETE',
      path: '/notifications/push/tokens',
      handler: _handleRemoveAllTokens,
    );
  }

  static Future<MockResponse> _handleGetAll(RequestOptions options) async {
    return MockResponse.success([
      {
        'id': 'notif-1',
        'userId': 'user-123',
        'type': 'transactionComplete',
        'title': 'Money received',
        'body': 'You received \$50.00 from +225 07 12 34 56 78',
        'data': {
          'transactionId': 'txn-001',
          'amount': 50.0,
          'from': '+225 07 12 34 56 78',
        },
        'isRead': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
        'readAt': null,
      },
      {
        'id': 'notif-2',
        'userId': 'user-123',
        'type': 'securityAlert',
        'title': 'New device login',
        'body': 'Your account was accessed from a new iPhone in Abidjan',
        'data': {
          'deviceId': 'device-456',
          'location': 'Abidjan, Côte d\'Ivoire',
        },
        'isRead': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'readAt': null,
      },
      {
        'id': 'notif-3',
        'userId': 'user-123',
        'type': 'transactionComplete',
        'title': 'Deposit successful',
        'body': 'Your deposit of \$100.00 via Orange Money is complete',
        'data': {
          'transactionId': 'txn-002',
          'amount': 100.0,
          'provider': 'Orange Money',
        },
        'isRead': true,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'readAt': DateTime.now()
            .subtract(const Duration(hours: 20))
            .toIso8601String(),
      },
      {
        'id': 'notif-4',
        'userId': 'user-123',
        'type': 'promotion',
        'title': 'Limited time offer!',
        'body': 'Invite 3 friends and get 500 XOF bonus. Offer ends soon!',
        'data': {'campaignId': 'promo-001', 'route': '/referrals'},
        'isRead': true,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'readAt': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 'notif-5',
        'userId': 'user-123',
        'type': 'lowBalance',
        'title': 'Low balance alert',
        'body':
            'Your balance is below 100 USDC. Top up to avoid transaction failures.',
        'data': {'currentBalance': 85.50, 'threshold': 100.0},
        'isRead': true,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        'readAt': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
    ]);
  }

  static Future<MockResponse> _handleGetPreferences(
    RequestOptions options,
  ) async {
    return MockResponse.success(NotificationsMockState.preferences);
  }

  static Future<MockResponse> _handleUpdatePreferences(
    RequestOptions options,
  ) async {
    final data = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : const <String, dynamic>{};
    NotificationsMockState.preferences = {
      ...NotificationsMockState.preferences,
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    return MockResponse.success(NotificationsMockState.preferences);
  }

  static Future<MockResponse> _handleGetUnreadCount(
    RequestOptions options,
  ) async {
    return MockResponse.success({'count': 2});
  }

  static Future<MockResponse> _handleMarkAsRead(RequestOptions options) async {
    return MockResponse.success({'success': true});
  }

  static Future<MockResponse> _handleMarkAllAsRead(
    RequestOptions options,
  ) async {
    return MockResponse.success({'success': true});
  }

  static Future<MockResponse> _handleRegisterToken(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'success': true,
      'message': 'Token registered successfully',
    });
  }

  static Future<MockResponse> _handleRemoveToken(RequestOptions options) async {
    return MockResponse.success({
      'success': true,
      'message': 'Token removed successfully',
    });
  }

  static Future<MockResponse> _handleRemoveAllTokens(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'success': true,
      'message': 'All tokens removed successfully',
    });
  }
}
