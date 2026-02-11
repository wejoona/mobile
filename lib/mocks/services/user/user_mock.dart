import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// User profile mock service.
class UserMock {
  static void register(MockInterceptor interceptor) {
    // GET /user/profile
    interceptor.register(
      method: 'GET',
      path: '/user/profile',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'id': 'usr_001',
          'phone': '+22507080910',
          'displayName': 'Ben Ouattara',
          'firstName': 'Ben',
          'lastName': 'Ouattara',
          'email': 'ben@korido.co',
          'avatarUrl': null,
          'preferredLocale': 'fr',
          'kycLevel': 'standard',
          'kycStatus': 'verified',
          'isActive': true,
          'createdAt': '2025-12-01T08:00:00Z',
          'updatedAt': '2026-02-10T14:30:00Z',
        });
      },
    );

    // PUT /user/profile
    interceptor.register(
      method: 'PUT',
      path: '/user/profile',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'id': 'usr_001',
          'phone': '+22507080910',
          'displayName': data?['firstName'] ?? 'Ben Ouattara',
          'firstName': data?['firstName'] ?? 'Ben',
          'lastName': data?['lastName'] ?? 'Ouattara',
          'email': data?['email'] ?? 'ben@korido.co',
          'avatarUrl': null,
          'preferredLocale': 'fr',
          'isActive': true,
          'createdAt': '2025-12-01T08:00:00Z',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      },
    );

    // POST /user/avatar
    interceptor.register(
      method: 'POST',
      path: '/user/avatar',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'avatarUrl': 'https://api.korido.co/uploads/avatars/usr_001_mock.jpg',
          'message': 'Avatar uploaded',
        });
      },
    );

    // DELETE /user/avatar
    interceptor.register(
      method: 'DELETE',
      path: '/user/avatar',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {'message': 'Avatar removed'});
      },
    );

    // PUT /user/locale
    interceptor.register(
      method: 'PUT',
      path: '/user/locale',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {'locale': data?['locale'] ?? 'fr', 'message': 'Locale updated'});
      },
    );

    // GET /user/limits
    interceptor.register(
      method: 'GET',
      path: '/user/limits',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'dailyLimit': 1000.0,
          'dailyUsed': 150.0,
          'weeklyLimit': 5000.0,
          'weeklyUsed': 850.0,
          'monthlyLimit': 15000.0,
          'monthlyUsed': 2500.0,
          'singleTransactionMax': 500.0,
          'currency': 'USDC',
        });
      },
    );

    // GET /user/limits/usage
    interceptor.register(
      method: 'GET',
      path: '/user/limits/usage',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'dailyUsed': 150.0,
          'weeklyUsed': 850.0,
          'monthlyUsed': 2500.0,
          'resetAt': DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
        });
      },
    );

    // GET /wallet/transactions/stats
    interceptor.register(
      method: 'GET',
      path: '/wallet/transactions/stats',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'totalCount': 47,
          'depositCount': 12,
          'withdrawalCount': 8,
          'transferCount': 27,
          'totalDeposited': 5200.00,
          'totalWithdrawn': 1800.00,
          'totalTransferred': 3100.00,
          'netFlow': 3400.00,
          'categories': [
            {'category': 'transfers', 'totalAmount': 3100.00, 'transactionCount': 27, 'percentageOfTotal': 52.0},
            {'category': 'bills', 'totalAmount': 800.00, 'transactionCount': 5, 'percentageOfTotal': 13.0},
            {'category': 'telecom', 'totalAmount': 600.00, 'transactionCount': 8, 'percentageOfTotal': 10.0},
            {'category': 'food', 'totalAmount': 400.00, 'transactionCount': 4, 'percentageOfTotal': 7.0},
            {'category': 'transport', 'totalAmount': 300.00, 'transactionCount': 3, 'percentageOfTotal': 5.0},
          ],
        });
      },
    );

    // GET /notifications
    interceptor.register(
      method: 'GET',
      path: '/notifications',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'data': [
            {'id': 'ntf_001', 'title': 'Transfer Received', 'body': 'You received \$50.00 from Amadou Diallo', 'type': 'transaction', 'isRead': false, 'createdAt': '2026-02-11T05:30:00Z'},
            {'id': 'ntf_002', 'title': 'KYC Approved', 'body': 'Your identity verification has been approved', 'type': 'kyc', 'isRead': true, 'createdAt': '2026-02-10T14:00:00Z'},
            {'id': 'ntf_003', 'title': 'Security Alert', 'body': 'New device logged in to your account', 'type': 'security', 'isRead': false, 'createdAt': '2026-02-09T20:15:00Z'},
            {'id': 'ntf_004', 'title': 'Deposit Confirmed', 'body': 'Your deposit of \$200.00 has been confirmed', 'type': 'transaction', 'isRead': true, 'createdAt': '2026-02-08T11:00:00Z'},
          ],
        });
      },
    );

    // GET /health/time
    interceptor.register(
      method: 'GET',
      path: '/health/time',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {
          'serverTime': DateTime.now().toIso8601String(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'timezone': 'UTC',
        });
      },
    );

    // GET /health/version
    interceptor.register(
      method: 'GET',
      path: '/health/version',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(statusCode: 200, data: {'version': '1.2.3', 'buildDate': '2026-02-11', 'environment': 'mock'});
      },
    );
  }
}
