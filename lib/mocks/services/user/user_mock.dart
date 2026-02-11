import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// User profile mock service.
class UserMock {
  static void register(MockInterceptor interceptor) {
    // GET /user/profile
    interceptor.register(
      method: 'GET',
      path: '/user/profile',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'avatarUrl': 'https://api.korido.co/uploads/avatars/usr_001_mock.jpg',
          'message': 'Avatar uploaded',
        });
      },
    );

    // DELETE /user/avatar
    interceptor.register(
      method: 'DELETE',
      path: '/user/avatar',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'message': 'Avatar removed'});
      },
    );

    // PUT /user/locale
    interceptor.register(
      method: 'PUT',
      path: '/user/locale',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'locale': data?['locale'] ?? 'fr', 'message': 'Locale updated'});
      },
    );

    // GET /user/limits
    interceptor.register(
      method: 'GET',
      path: '/user/limits',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {
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
      handler: (uri, headers, data) async {
        return MockResponse(200, {'version': '1.2.3', 'buildDate': '2026-02-11', 'environment': 'mock'});
      },
    );
  }
}
