import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

class LimitsMock {
  static void register(MockInterceptor interceptor) {
    // GET /wallet/limits
    interceptor.register(
      method: 'GET',
      path: '/wallet/limits',
      handler: _handleGetLimits,
    );
  }

  static Future<MockResponse> _handleGetLimits(RequestOptions options) async {
    // Simulate different KYC tiers based on random selection
    final tierScenarios = [
      // Tier 0 - Unverified
      {
        'dailyLimit': 100.0,
        'monthlyLimit': 500.0,
        'dailyUsed': 45.0,
        'monthlyUsed': 180.0,
        'kycTier': 0,
        'tierName': 'Unverified',
        'nextTierName': 'Basic',
        'nextTierDailyLimit': 500.0,
        'nextTierMonthlyLimit': 2000.0,
      },
      // Tier 1 - Basic (nearing daily limit)
      {
        'dailyLimit': 500.0,
        'monthlyLimit': 2000.0,
        'dailyUsed': 420.0,
        'monthlyUsed': 1250.0,
        'kycTier': 1,
        'tierName': 'Basic',
        'nextTierName': 'Verified',
        'nextTierDailyLimit': 2000.0,
        'nextTierMonthlyLimit': 10000.0,
      },
      // Tier 2 - Verified (at daily limit)
      {
        'dailyLimit': 2000.0,
        'monthlyLimit': 10000.0,
        'dailyUsed': 2000.0,
        'monthlyUsed': 5500.0,
        'kycTier': 2,
        'tierName': 'Verified',
        'nextTierName': 'Premium',
        'nextTierDailyLimit': 10000.0,
        'nextTierMonthlyLimit': 50000.0,
      },
      // Tier 3 - Premium (max tier)
      {
        'dailyLimit': 10000.0,
        'monthlyLimit': 50000.0,
        'dailyUsed': 1250.0,
        'monthlyUsed': 12500.0,
        'kycTier': 3,
        'tierName': 'Premium',
        'nextTierName': null,
        'nextTierDailyLimit': null,
        'nextTierMonthlyLimit': null,
      },
    ];

    // Return Tier 0 scenario by default for new users (no usage yet)
    return MockResponse.success({
      'dailyLimit': 100.0,
      'monthlyLimit': 500.0,
      'dailyUsed': 0.0,
      'monthlyUsed': 0.0,
      'singleTransactionLimit': 50.0,
      'withdrawalLimit': 50.0,
      'kycTier': 0,
      'tierName': 'Unverified',
      'nextTierName': 'Basic',
      'nextTierDailyLimit': 500.0,
      'nextTierMonthlyLimit': 2000.0,
    });
  }
}
