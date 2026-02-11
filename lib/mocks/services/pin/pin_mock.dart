import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// PIN API mocks
class PinMock {
  static void register(MockInterceptor interceptor) {
    // POST /api/v1/user/pin/set
    interceptor.register(
      method: 'POST',
      path: '/api/v1/user/pin/set',
      handler: _handleSetPin,
    );

    // POST /api/v1/user/pin/change
    interceptor.register(
      method: 'POST',
      path: '/api/v1/user/pin/change',
      handler: _handleChangePin,
    );

    // POST /api/v1/user/pin/verify
    interceptor.register(
      method: 'POST',
      path: '/api/v1/user/pin/verify',
      handler: _handleVerifyPin,
    );

    // POST /api/v1/user/pin/reset
    interceptor.register(
      method: 'POST',
      path: '/api/v1/user/pin/reset',
      handler: _handleResetPin,
    );
  }

  /// Handle set PIN
  static Future<MockResponse> _handleSetPin(RequestOptions options) async {
    final pinHash = options.data['pinHash'] as String?;
    if (pinHash == null || pinHash.isEmpty) {
      return MockResponse.badRequest('PIN hash is required');
    }

    return MockResponse.success({
      'success': true,
      'message': 'PIN set successfully',
    });
  }

  /// Handle change PIN
  static Future<MockResponse> _handleChangePin(RequestOptions options) async {
    final oldPinHash = options.data['oldPinHash'] as String?;
    final newPinHash = options.data['newPinHash'] as String?;

    if (oldPinHash == null || newPinHash == null) {
      return MockResponse.badRequest('Both old and new PIN hashes are required');
    }

    // Mock verification - accept any hash
    return MockResponse.success({
      'success': true,
      'message': 'PIN changed successfully',
    });
  }

  /// Handle verify PIN
  static Future<MockResponse> _handleVerifyPin(RequestOptions options) async {
    final pinHash = options.data['pinHash'] as String?;

    if (pinHash == null || pinHash.isEmpty) {
      return MockResponse.badRequest('PIN hash is required');
    }

    // Mock: Accept any hash for testing
    return MockResponse.success({
      'verified': true,
      'pinToken': 'mock_pin_token_${DateTime.now().millisecondsSinceEpoch}',
      'expiresIn': 300, // 5 minutes
    });
  }

  /// Handle reset PIN
  static Future<MockResponse> _handleResetPin(RequestOptions options) async {
    final otp = options.data['otp'] as String?;
    final newPinHash = options.data['newPinHash'] as String?;

    if (otp == null || newPinHash == null) {
      return MockResponse.badRequest('OTP and new PIN hash are required');
    }

    // Mock: Accept 123456 as valid OTP
    if (otp != '123456') {
      return MockResponse.badRequest('Invalid OTP');
    }

    return MockResponse.success({
      'success': true,
      'message': 'PIN reset successfully',
    });
  }
}
