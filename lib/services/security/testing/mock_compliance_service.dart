import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock compliance service for testing.
class MockComplianceService {
  bool _isCompliant = true;
  String _kycTier = 'verified';

  void setCompliant(bool value) => _isCompliant = value;
  void setKycTier(String tier) => _kycTier = tier;

  bool get isCompliant => _isCompliant;
  String get kycTier => _kycTier;

  Future<bool> checkCompliance(String userId) async => _isCompliant;

  Future<bool> checkTransactionLimit(double amount) async {
    final limit = _kycTier == 'verified' ? 2000000.0 : 200000.0;
    return amount <= limit;
  }
}

final mockComplianceServiceProvider = Provider<MockComplianceService>((ref) {
  return MockComplianceService();
});
