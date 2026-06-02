import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_contract.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';

class UserMockState {
  static const mockAvatarThumb =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

  static String? avatarUrl;
  static String? avatarThumb;

  static void reset() {
    avatarUrl = null;
    avatarThumb = null;
  }

  static void setAvatar({String? url, String? thumb = mockAvatarThumb}) {
    avatarUrl = url;
    avatarThumb = thumb;
  }
}

/// User profile mock service.
class UserMock {
  static void register(MockInterceptor interceptor) {
    // GET /user/profile
    interceptor.register(
      method: 'GET',
      path: '/user/profile',
      legacyHandler: (uri, headers, data) async {
        final user = _currentUser();
        if (user == null) {
          return MockResponse.unauthorized();
        }

        return MockResponse(statusCode: 200, data: _profileJson(user));
      },
    );

    // PUT /user/profile
    interceptor.register(
      method: 'PUT',
      path: '/user/profile',
      legacyHandler: (uri, headers, data) async {
        final user = _currentUser();
        if (user == null) {
          return MockResponse.unauthorized();
        }

        final payload = data is Map<String, dynamic>
            ? data
            : const <String, dynamic>{};
        final updatedUser = UserResponse(
          id: user.id,
          phone: user.phone,
          firstName: payload['firstName'] as String? ?? user.firstName,
          lastName: payload['lastName'] as String? ?? user.lastName,
          email: payload['email'] as String? ?? user.email,
          countryCode: user.countryCode,
          kycStatus: user.kycStatus,
          hasPinSet: user.hasPinSet,
          createdAt: user.createdAt,
        );
        AuthMockState.users[user.phone] = updatedUser;

        return MockResponse(statusCode: 200, data: _profileJson(updatedUser));
      },
    );

    // POST /user/avatar
    interceptor.register(
      method: 'POST',
      path: '/user/avatar',
      legacyHandler: (uri, headers, data) async {
        UserMockState.setAvatar();
        return MockResponse(
          statusCode: 200,
          data: {
            'avatarUrl': UserMockState.avatarUrl,
            'avatarThumb': UserMockState.avatarThumb,
            'message': 'Avatar uploaded',
          },
        );
      },
    );

    // DELETE /user/avatar
    interceptor.register(
      method: 'DELETE',
      path: '/user/avatar',
      legacyHandler: (uri, headers, data) async {
        UserMockState.reset();
        return MockResponse(
          statusCode: 200,
          data: {'message': 'Avatar removed'},
        );
      },
    );

    // PUT /user/locale
    interceptor.register(
      method: 'PUT',
      path: '/user/locale',
      legacyHandler: (uri, headers, data) async {
        final payload = data is Map<String, dynamic>
            ? data
            : const <String, dynamic>{};
        return MockResponse(
          statusCode: 200,
          data: {
            'locale': payload['locale'] as String? ?? 'fr',
            'message': 'Locale updated',
          },
        );
      },
    );

    // GET /user/limits
    interceptor.register(
      method: 'GET',
      path: '/user/limits',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'dailyLimit': 1000.0,
            'dailyUsed': 150.0,
            'weeklyLimit': 5000.0,
            'weeklyUsed': 850.0,
            'monthlyLimit': 15000.0,
            'monthlyUsed': 2500.0,
            'singleTransactionMax': 500.0,
            'currency': 'USDC',
          },
        );
      },
    );

    // GET /user/limits/usage
    interceptor.register(
      method: 'GET',
      path: '/user/limits/usage',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'dailyUsed': 150.0,
            'weeklyUsed': 850.0,
            'monthlyUsed': 2500.0,
            'resetAt': DateTime.now()
                .add(const Duration(hours: 8))
                .toIso8601String(),
          },
        );
      },
    );

    // GET /wallet/transactions/stats
    interceptor.register(
      method: 'GET',
      path: '/wallet/transactions/stats',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'totalCount': 47,
            'depositCount': 12,
            'withdrawalCount': 8,
            'transferCount': 27,
            'totalDeposited': 5200.00,
            'totalWithdrawn': 1800.00,
            'totalTransferred': 3100.00,
            'netFlow': 3400.00,
            'categories': [
              {
                'category': 'transfers',
                'totalAmount': 3100.00,
                'transactionCount': 27,
                'percentageOfTotal': 52.0,
              },
              {
                'category': 'bills',
                'totalAmount': 800.00,
                'transactionCount': 5,
                'percentageOfTotal': 13.0,
              },
              {
                'category': 'telecom',
                'totalAmount': 600.00,
                'transactionCount': 8,
                'percentageOfTotal': 10.0,
              },
              {
                'category': 'food',
                'totalAmount': 400.00,
                'transactionCount': 4,
                'percentageOfTotal': 7.0,
              },
              {
                'category': 'transport',
                'totalAmount': 300.00,
                'transactionCount': 3,
                'percentageOfTotal': 5.0,
              },
            ],
          },
        );
      },
    );

    // GET /notifications
    interceptor.register(
      method: 'GET',
      path: '/notifications',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'data': [
              {
                'id': 'ntf_001',
                'title': 'Transfer Received',
                'body': 'You received \$50.00 from Amadou Diallo',
                'type': 'transaction',
                'isRead': false,
                'createdAt': '2026-02-11T05:30:00Z',
              },
              {
                'id': 'ntf_002',
                'title': 'KYC Approved',
                'body': 'Your identity verification has been approved',
                'type': 'kyc',
                'isRead': true,
                'createdAt': '2026-02-10T14:00:00Z',
              },
              {
                'id': 'ntf_003',
                'title': 'Security Alert',
                'body': 'New device logged in to your account',
                'type': 'security',
                'isRead': false,
                'createdAt': '2026-02-09T20:15:00Z',
              },
              {
                'id': 'ntf_004',
                'title': 'Deposit Confirmed',
                'body': 'Your deposit of \$200.00 has been confirmed',
                'type': 'transaction',
                'isRead': true,
                'createdAt': '2026-02-08T11:00:00Z',
              },
            ],
          },
        );
      },
    );

    // GET /health/time
    interceptor.register(
      method: 'GET',
      path: '/health/time',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'serverTime': DateTime.now().toIso8601String(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'timezone': 'UTC',
          },
        );
      },
    );

    // GET /health/version
    interceptor.register(
      method: 'GET',
      path: '/health/version',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'version': '1.2.3',
            'buildDate': '2026-02-11',
            'environment': 'mock',
          },
        );
      },
    );
  }

  static UserResponse? _currentUser() {
    final currentUserId = AuthMockState.currentUserId;
    if (currentUserId == null) return null;

    for (final user in AuthMockState.users.values) {
      if (user.id == currentUserId) {
        return user;
      }
    }
    return null;
  }

  static Map<String, dynamic> _profileJson(UserResponse user) {
    final displayName = [user.firstName, user.lastName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();

    return {
      'id': user.id,
      'phone': user.phone,
      'phoneVerified': true,
      'username': null,
      'displayName': displayName.isNotEmpty ? displayName : user.phone,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'emailVerified': user.email != null && user.email!.isNotEmpty,
      'avatarUrl': UserMockState.avatarUrl,
      'avatarThumb': UserMockState.avatarThumb,
      'preferredLocale': 'fr',
      'countryCode': user.countryCode,
      'kycLevel': 'standard',
      'kycStatus': user.kycStatus == 'not_started'
          ? 'verified'
          : user.kycStatus,
      'kycRejectionReason': null,
      'canTransact': true,
      'canWithdraw': true,
      'hasPin': true,
      'role': 'user',
      'status': 'active',
      'isActive': true,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
