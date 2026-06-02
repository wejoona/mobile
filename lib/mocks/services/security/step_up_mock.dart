import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Step-up risk mocks for transaction flows.
class StepUpMock {
  static void register(MockInterceptor interceptor) {
    interceptor.register(
      method: 'POST',
      path: '/step-up/transaction',
      handler: _handleTransactionRisk,
    );
    interceptor.register(
      method: 'POST',
      path: '/step-up/operation',
      handler: _handleOperationRisk,
    );
    interceptor.register(
      method: 'POST',
      path: '/step-up/validate',
      handler: _handleValidate,
    );
  }

  static Future<MockResponse> _handleTransactionRisk(options) async {
    return MockResponse.success({'success': true, 'data': _greenDecision()});
  }

  static Future<MockResponse> _handleOperationRisk(options) async {
    return MockResponse.success({'success': true, 'data': _greenDecision()});
  }

  static Future<MockResponse> _handleValidate(options) async {
    return MockResponse.success({'success': true, 'verified': true});
  }

  static Map<String, dynamic> _greenDecision() {
    return {
      'flow': 'green',
      'riskScore': 10,
      'riskLevel': 'low',
      'stepUpRequired': false,
      'stepUpType': 'none',
      'reason': 'Low-risk mock transaction',
      'factors': <String>['mock_mode'],
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 5))
          .toIso8601String(),
    };
  }
}
