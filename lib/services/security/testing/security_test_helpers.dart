import 'package:usdc_wallet/services/security/testing/mock_security_service.dart';
import 'package:usdc_wallet/services/security/testing/mock_compliance_service.dart';
import 'package:usdc_wallet/services/security/testing/mock_auth_service.dart';
import 'package:usdc_wallet/services/security/testing/mock_network_service.dart';

/// Helper utilities for security testing.
class SecurityTestHelpers {
  /// Create a fully configured test container with mock services.
  static List<dynamic> createMockOverrides({
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
