import '../../base/mock_interceptor.dart';

/// User profile mock service.
class UserMock {
  static void register(MockInterceptor interceptor) {
    // GET /user/profile
    interceptor.registerGet('/user/profile', (uri, headers, data) {
      return MockResponse(200, {
        'id': 'usr_001',
        'phone': '+22507080910',
        'displayName': 'Ben Ouattara',
        'email': 'ben@korido.co',
        'avatarUrl': null,
        'preferredLocale': 'fr',
        'kycLevel': 'standard',
        'kycStatus': 'verified',
        'isActive': true,
        'createdAt': '2025-12-01T08:00:00Z',
        'updatedAt': '2026-02-10T14:30:00Z',
      });
    });

    // PUT /user/profile
    interceptor.registerPut('/user/profile', (uri, headers, data) {
      return MockResponse(200, {
        'id': 'usr_001',
        'phone': '+22507080910',
        'displayName': data?['displayName'] ?? 'Ben Ouattara',
        'email': data?['email'] ?? 'ben@korido.co',
        'avatarUrl': null,
        'preferredLocale': 'fr',
        'kycLevel': 'standard',
        'kycStatus': 'verified',
        'isActive': true,
        'createdAt': '2025-12-01T08:00:00Z',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });

    // POST /user/avatar
    interceptor.registerPost('/user/avatar', (uri, headers, data) {
      return MockResponse(200, {
        'avatarUrl': 'https://api.korido.co/uploads/avatars/usr_001_${DateTime.now().millisecondsSinceEpoch}.jpg',
        'message': 'Avatar uploaded successfully',
      });
    });

    // DELETE /user/avatar
    interceptor.registerDelete('/user/avatar', (uri, headers, data) {
      return MockResponse(200, {'message': 'Avatar removed'});
    });

    // PUT /user/locale
    interceptor.registerPut('/user/locale', (uri, headers, data) {
      return MockResponse(200, {
        'locale': data?['locale'] ?? 'fr',
        'message': 'Locale updated',
      });
    });

    // GET /user/limits
    interceptor.registerGet('/user/limits', (uri, headers, data) {
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
    });

    // GET /user/limits/usage
    interceptor.registerGet('/user/limits/usage', (uri, headers, data) {
      return MockResponse(200, {
        'dailyUsed': 150.0,
        'weeklyUsed': 850.0,
        'monthlyUsed': 2500.0,
        'resetAt': DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
      });
    });
  }
}
