import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Referrals mock service.
class ReferralsMock {
  static void register(MockInterceptor interceptor) {
    // GET /referrals
    interceptor.register(
      method: 'GET',
      path: '/referrals',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'referralCode': 'KORIDO-BEN2026',
          'referralLink': 'https://korido.app/referral/KORIDO-BEN2026',
          'totalReferrals': 5,
          'successfulReferrals': 3,
          'totalEarned': 15.00,
          'currency': 'USDC',
          'referrals': [
            {'id': 'ref_001', 'referredName': 'Amadou Diallo', 'status': 'completed', 'reward': 5.00, 'createdAt': '2026-01-15T10:00:00Z'},
            {'id': 'ref_002', 'referredName': 'Fatou Koné', 'status': 'completed', 'reward': 5.00, 'createdAt': '2026-01-20T14:30:00Z'},
            {'id': 'ref_003', 'referredName': 'Ibrahim Touré', 'status': 'completed', 'reward': 5.00, 'createdAt': '2026-02-01T09:15:00Z'},
            {'id': 'ref_004', 'referredName': 'Mariam Bamba', 'status': 'pending', 'reward': null, 'createdAt': '2026-02-08T16:45:00Z'},
            {'id': 'ref_005', 'referredName': 'Youssouf Cissé', 'status': 'pending', 'reward': null, 'createdAt': '2026-02-10T11:00:00Z'},
          ],
        });
      },
    );

    // GET /referrals/code
    interceptor.register(
      method: 'GET',
      path: '/referrals/code',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'code': 'KORIDO-BEN2026'});
      },
    );

    // POST /referrals/apply
    interceptor.register(
      method: 'POST',
      path: '/referrals/apply',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'success': true, 'message': 'Referral code applied', 'bonus': 5.00});
      },
    );
  }
}
