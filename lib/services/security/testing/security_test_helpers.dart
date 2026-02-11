import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_security_service.dart';
import 'mock_compliance_service.dart';
import 'mock_auth_service.dart';
import 'mock_network_service.dart';

/// Helper utilities for security testing.
class SecurityTestHelpers {
  /// Create a fully configured test container with mock services.
  static List<Override> createMockOverrides({
    bool isSecure = true,
    bool isCompliant = true,
    bool isAuthenticated = true,
    bool isOnline = true,
  }) {
    return [
      mockSecurityServiceProvider.overrideWithValue(
        MockSecurityService()..setSecure(isSecure),
      ),
      mockComplianceServiceProvider.overrideWithValue(
        MockComplianceService()..setCompliant(isCompliant),
      ),
      mockAuthServiceProvider.overrideWithValue(
        MockAuthService(),
      ),
      mockNetworkServiceProvider.overrideWithValue(
        MockNetworkService()..setOnline(isOnline),
      ),
    ];
  }
}
