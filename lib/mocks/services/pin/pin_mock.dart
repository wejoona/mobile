import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// PIN API mocks
class PinMock {
  static void register(MockInterceptor interceptor) {
    for (final path in const [
      '/user/pin/set',
      '/wallet/pin/set',
      '/api/v1/user/pin/set',
    ]) {
      interceptor.register(method: 'POST', path: path, handler: _handleSetPin);
    }

    for (final path in const ['/user/pin/change', '/api/v1/user/pin/change']) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleChangePin,
      );
    }

    for (final path in const [
      '/user/pin/verify',
      '/wallet/pin/verify',
      '/api/v1/user/pin/verify',
    ]) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleVerifyPin,
      );
    }

    for (final path in const ['/user/pin/reset', '/api/v1/user/pin/reset']) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleResetPin,
      );
    }
  }

  /// Handle set PIN
  static Future<MockResponse> _handleSetPin(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final pinHash = data['pinHash'] as String?;
    final pin = data['pin'] as String?;
    final confirmPin = data['confirmPin'] as String?;
    if ((pinHash == null || pinHash.isEmpty) && (pin == null || pin.isEmpty)) {
      return MockResponse.badRequest('PIN is required');
    }
    if (confirmPin != null && confirmPin != pin) {
      return MockResponse.badRequest('PINs do not match');
    }

    return MockResponse.success({
      'success': true,
      'message': 'PIN set successfully',
    });
  }

  /// Handle change PIN
  static Future<MockResponse> _handleChangePin(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final oldPinHash = data['oldPinHash'] as String?;
    final newPinHash = data['newPinHash'] as String?;
    final oldPin = data['oldPin'] as String?;
    final newPin = data['newPin'] as String?;

    final hasHashPair = oldPinHash != null && newPinHash != null;
    final hasPinPair = oldPin != null && newPin != null;
    if (!hasHashPair && !hasPinPair) {
      return MockResponse.badRequest(
        'Both old and new PIN values are required',
      );
    }

    // Mock verification - accept any hash
    return MockResponse.success({
      'success': true,
      'message': 'PIN changed successfully',
    });
  }

  /// Handle verify PIN
  static Future<MockResponse> _handleVerifyPin(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final pinHash = data['pinHash'] as String?;
    final pin = data['pin'] as String?;

    if ((pinHash == null || pinHash.isEmpty) && (pin == null || pin.isEmpty)) {
      return MockResponse.badRequest('PIN is required');
    }

    // Mock: Accept any hash for testing
    return MockResponse.success({
      'valid': true,
      'verified': true,
      'message': 'PIN verified successfully',
      'pinToken': 'mock_pin_token_${DateTime.now().millisecondsSinceEpoch}',
      'expiresIn': 300, // 5 minutes
    });
  }

  /// Handle reset PIN
  static Future<MockResponse> _handleResetPin(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final otp = data['otp'] as String?;
    final newPinHash = data['newPinHash'] as String?;
    final newPin = data['newPin'] as String?;
    final stepUpChallengeToken = data['stepUpChallengeToken'] as String?;

    if (otp == null ||
        stepUpChallengeToken == null ||
        (newPinHash == null && newPin == null)) {
      return MockResponse.badRequest(
        'OTP, step-up verification, and new PIN are required',
      );
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
