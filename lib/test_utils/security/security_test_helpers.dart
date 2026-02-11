import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Test helpers for security-related tests.
class SecurityTestHelpers {
  /// Create a [ProviderContainer] with security service overrides.
  static ProviderContainer createSecurityTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(overrides: overrides);
  }

  /// Generate a fake device fingerprint for testing.
  static Map<String, dynamic> fakeFingerprintData({
    bool isCompromised = false,
    bool isPhysical = true,
    bool hasBiometrics = true,
  }) {
    return {
      'deviceId': 'test-device-001',
      'platform': 'android',
      'isCompromised': isCompromised,
      'isPhysicalDevice': isPhysical,
      'biometricsAvailable': hasBiometrics,
      'model': 'Test Device',
      'osVersion': '14.0',
    };
  }

  /// Generate a fake auth token for testing.
  static String fakeAuthToken({
    String userId = 'test-user-001',
    Duration expiry = const Duration(hours: 1),
  }) {
    return 'test_token_${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Simulate a failed login sequence.
  static Future<void> simulateFailedLogins(
    Function(String pin) attemptLogin,
    int count,
  ) async {
    for (int i = 0; i < count; i++) {
      await attemptLogin('000000');
    }
  }

  /// Verify security headers are present in a request.
  static void expectSecurityHeaders(Map<String, dynamic> headers) {
    expect(headers.containsKey('X-Device-Id'), isTrue);
    expect(headers.containsKey('X-Request-Timestamp'), isTrue);
  }
}
