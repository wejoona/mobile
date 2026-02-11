import '../../base/mock_interceptor.dart';

/// Wallet balance and stats mock.
class WalletStatsMock {
  static void register(MockInterceptor interceptor) {
    // GET /wallet/balance
    interceptor.register(
      method: 'GET',
      path: '/wallet/balance',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'balance': 2450.75,
          'available': 2450.75,
          'pending': 0.00,
          'total': 2450.75,
          'currency': 'USDC',
          'updatedAt': DateTime.now().toIso8601String(),
        });
      },
    );

    // GET /alerts
    interceptor.register(
      method: 'GET',
      path: '/alerts',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'data': [
            {
              'id': 'alert_001',
              'title': 'Complétez votre KYC',
              'message': 'Vérifiez votre identité pour augmenter vos limites de transaction.',
              'type': 'info',
              'isDismissible': true,
              'actionUrl': '/kyc',
              'createdAt': '2026-02-10T08:00:00Z',
            },
          ],
        });
      },
    );

    // GET /devices
    interceptor.register(
      method: 'GET',
      path: '/devices',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'data': [
            {
              'id': 'dev_001',
              'name': 'iPhone 16 Pro',
              'platform': 'ios',
              'lastActive': DateTime.now().toIso8601String(),
              'isCurrent': true,
              'fingerprint': 'abc123',
              'createdAt': '2025-12-01T10:00:00Z',
            },
            {
              'id': 'dev_002',
              'name': 'iPad Air',
              'platform': 'ios',
              'lastActive': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
              'isCurrent': false,
              'fingerprint': 'def456',
              'createdAt': '2026-01-15T14:00:00Z',
            },
          ],
        });
      },
    );

    // DELETE /devices/:id
    interceptor.register(
      method: 'DELETE',
      path: '/devices/dev_002',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'message': 'Device removed'});
      },
    );

    // GET /referrals/stats
    interceptor.register(
      method: 'GET',
      path: '/referrals/stats',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'totalReferred': 5,
          'activeReferred': 3,
          'totalEarned': 15.00,
          'pendingRewards': 10.00,
          'referralCode': 'KORIDO-BEN2026',
        });
      },
    );
  }
}
