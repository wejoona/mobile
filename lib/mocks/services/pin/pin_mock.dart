import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// PIN API mocks
class PinMock {
  static void register(MockInterceptor interceptor) {
    for (final path in _apiPaths(ApiEndpoints.userPinSet)) {
      interceptor.register(method: 'POST', path: path, handler: _handleSetPin);
    }

    for (final path in _apiPaths(ApiEndpoints.userPinChange)) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleChangePin,
      );
    }

    for (final path in _apiPaths(ApiEndpoints.userPinVerify)) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleVerifyPin,
      );
    }

    for (final path in _apiPaths(ApiEndpoints.userPinReset)) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleResetPin,
      );
    }
  }

  static List<String> _apiPaths(String path) => [path, '/api/v1$path'];

  /// Handle set PIN
  static Future<MockResponse> _handleSetPin(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final pinHash = data['pinHash'] as String?;
    if (!_isSha256(pinHash)) {
      return MockResponse.badRequest('PIN hash must be a valid SHA256 hash');
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

    if (!_isSha256(oldPinHash) || !_isSha256(newPinHash)) {
      return MockResponse.badRequest(
        'Both old and new PIN hashes are required',
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

    if (!_isSha256(pinHash)) {
      return MockResponse.badRequest('PIN hash must be a valid SHA256 hash');
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
    final data = options.data as Map<String, dynamic>? ?? {};
    final otp = data['otp'] as String?;
    final newPinHash = data['newPinHash'] as String?;
    final stepUpChallengeToken = data['stepUpChallengeToken'] as String?;

    if (otp == null || stepUpChallengeToken == null || !_isSha256(newPinHash)) {
      return MockResponse.badRequest(
        'OTP, step-up verification, and new PIN hash are required',
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

  static bool _isSha256(String? value) {
    return value != null && RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(value);
  }
}
