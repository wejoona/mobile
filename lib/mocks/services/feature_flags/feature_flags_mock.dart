import 'package:dio/dio.dart';
import '../../base/api_contract.dart';
import '../../base/mock_interceptor.dart';

/// Feature Flags Mock Data
///
/// Mocks the backend feature flags API endpoints.
class FeatureFlagsMock {
  /// Register mock endpoints
  static void register(MockInterceptor interceptor) {
    // GET /feature-flags/me - Get all flags for current user
    interceptor.register(
      method: 'GET',
      path: r'/feature-flags/me',
      handler: (options) async {
        await Future.delayed(const Duration(milliseconds: 300));

        return MockResponse.success({
          'flags': {
            // Backend-controlled flags (current state from requirements)
            'two_factor_auth': false,
            'external_transfers': true,
            'bill_payments': true,
            'savings_pots': false,
            'biometric_auth': true,
            'mobile_money_withdrawals': true,

            // MVP features (always on)
            'deposit': true,
            'send': true,
            'receive': true,
            'transactions': true,
            'kyc': true,

            // Phase 2+
            'withdraw': true,
            'off_ramp': true,
            'airtime': true,
            'bills': true,
            'savings': false,
            'virtual_cards': false,
            'split_bills': false,
            'recurring_transfers': false,
            'budget': false,
            'agent_network': false,
            'ussd': false,

            // Other features
            'referrals': true,
            'referral_program': true,
            'analytics': false,
            'currency_converter': true,
            'request_money': true,
            'scheduled_transfers': false,
            'saved_recipients': true,
            'merchant_qr': true,
            'payment_links': true,
          },
        });
      },
    );

    // GET /feature-flags/check/:key - Check single flag
    interceptor.register(
      method: 'GET',
      path: r'/feature-flags/check/[\w_]+',
      handler: (options) async {
        await Future.delayed(const Duration(milliseconds: 150));

        // Extract flag key from path
        final key = options.path.split('/').last;

        // Mock flag evaluation
        final mockFlags = {
          'two_factor_auth': false,
          'external_transfers': true,
          'bill_payments': true,
          'savings_pots': false,
          'biometric_auth': true,
          'mobile_money_withdrawals': true,
        };

        final isEnabled = mockFlags[key] ?? false;

        return MockResponse.success({
          'key': key,
          'isEnabled': isEnabled,
        });
      },
    );
  }
}
