import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Wallet balance and stats mock.
class WalletStatsMock {
  static void register(MockInterceptor interceptor) {
    // GET /alerts
    interceptor.register(
      method: 'GET',
      path: '/alerts',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'data': [
              {
                'id': 'alert_001',
                'title': 'Complétez votre KYC',
                'message':
                    'Vérifiez votre identité pour augmenter vos limites de transaction.',
                'type': 'info',
                'isDismissible': true,
                'actionUrl': '/kyc',
                'createdAt': '2026-02-10T08:00:00Z',
              },
            ],
          },
        );
      },
    );

    // GET /referrals/stats
    interceptor.register(
      method: 'GET',
      path: '/referrals/stats',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'totalReferred': 5,
            'activeReferred': 3,
            'totalEarned': 15.00,
            'pendingRewards': 10.00,
            'referralCode': 'KORIDO-BEN2026',
          },
        );
      },
    );
  }
}
