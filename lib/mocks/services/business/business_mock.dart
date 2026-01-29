import '../../base/mock_interceptor.dart';
import '../../base/api_contract.dart';

/// Business Mock - mock business account operations
class BusinessMock {
  static void register(MockInterceptor interceptor) {
    // GET /users/me/account-type - get account type
    interceptor.register(
      method: 'GET',
      path: '/users/me/account-type',
      handler: (options) async => MockResponse.success({
        'accountType': 'personal', // Default to personal
      }),
    );

    // POST /users/me/account-type - switch account type
    interceptor.register(
      method: 'POST',
      path: '/users/me/account-type',
      handler: (options) async {
        final accountType = options.data['accountType'] as String;
        return MockResponse.success({
          'accountType': accountType,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      },
    );

    // GET /business/profile - get business profile
    interceptor.register(
      method: 'GET',
      path: '/business/profile',
      handler: (options) async => MockResponse.success({
        'id': 'biz-123',
        'userId': 'user-456',
        'businessName': 'Amadou Trading Ltd',
        'registrationNumber': 'CI-2024-001234',
        'businessType': 'llc',
        'businessAddress': '123 Rue du Commerce, Abidjan, Côte d\'Ivoire',
        'taxId': 'TAX-225-12345',
        'isVerified': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );

    // POST /business/profile - create/update business profile
    interceptor.register(
      method: 'POST',
      path: '/business/profile',
      handler: (options) async {
        final data = options.data as Map<String, dynamic>;
        return MockResponse.success({
          'id': 'biz-${DateTime.now().millisecondsSinceEpoch}',
          'userId': 'user-456',
          'businessName': data['businessName'],
          'registrationNumber': data['registrationNumber'],
          'businessType': data['businessType'],
          'businessAddress': data['businessAddress'],
          'taxId': data['taxId'],
          'isVerified': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      },
    );
  }
}
