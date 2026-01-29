import 'package:dio/dio.dart';
import '../../base/mock_interceptor.dart';
import '../../base/api_contract.dart';

class KycMock {
  static void register(MockInterceptor interceptor) {
    // POST /user/kyc - Submit KYC documents
    interceptor.register(
      method: 'POST',
      path: '/api/v1/user/kyc',
      handler: _handleSubmitKyc,
    );

    // GET /user/profile - Includes KYC status
    interceptor.register(
      method: 'GET',
      path: '/api/v1/user/profile',
      handler: _handleGetProfile,
    );
  }

  static Future<MockResponse> _handleSubmitKyc(RequestOptions options) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    KycMockState.kycStatus = 'submitted';
    KycMockState.rejectionReason = null;

    return MockResponse.success({
      'message': 'KYC documents submitted successfully',
      'status': 'submitted',
    });
  }

  static Future<MockResponse> _handleGetProfile(RequestOptions options) async {
    return MockResponse.success({
      'id': 'user-1',
      'phone': '+2250700000000',
      'firstName': 'Amadou',
      'lastName': 'Diallo',
      'email': 'amadou@example.com',
      'kycStatus': KycMockState.kycStatus,
      'kycRejectionReason': KycMockState.rejectionReason,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}

/// Mock state for KYC
class KycMockState {
  static String kycStatus = 'pending'; // pending, submitted, approved, rejected, additional_info_needed
  static String? rejectionReason;

  static void reset() {
    kycStatus = 'pending';
    rejectionReason = null;
  }

  /// Simulate KYC approval (for testing)
  static void approve() {
    kycStatus = 'approved';
    rejectionReason = null;
  }

  /// Simulate KYC rejection (for testing)
  static void reject(String reason) {
    kycStatus = 'rejected';
    rejectionReason = reason;
  }

  /// Simulate additional info needed (for testing)
  static void requestAdditionalInfo(String reason) {
    kycStatus = 'additional_info_needed';
    rejectionReason = reason;
  }
}
