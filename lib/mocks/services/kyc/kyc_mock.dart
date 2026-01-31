import 'package:dio/dio.dart';
import '../../base/mock_interceptor.dart';
import '../../base/api_contract.dart';

class KycMock {
  static void register(MockInterceptor interceptor) {
    // POST /kyc/submit - Submit KYC documents
    interceptor.register(
      method: 'POST',
      path: '/kyc/submit',
      handler: _handleSubmitKyc,
    );

    // GET /kyc/status - Get KYC status
    interceptor.register(
      method: 'GET',
      path: '/kyc/status',
      handler: _handleGetStatus,
    );

    // GET /wallet/kyc/status - Wallet KYC status endpoint
    interceptor.register(
      method: 'GET',
      path: '/wallet/kyc/status',
      handler: _handleGetStatus,
    );

    // POST /wallet/kyc/submit - Wallet KYC submit
    interceptor.register(
      method: 'POST',
      path: '/wallet/kyc/submit',
      handler: _handleSubmitKyc,
    );

    // POST /kyc/address - KYC address verification
    interceptor.register(
      method: 'POST',
      path: '/kyc/address',
      handler: _handleSubmitKyc,
    );

    // POST /kyc/video - KYC video verification
    interceptor.register(
      method: 'POST',
      path: '/kyc/video',
      handler: _handleSubmitKyc,
    );

    // POST /kyc/additional-documents
    interceptor.register(
      method: 'POST',
      path: '/kyc/additional-documents',
      handler: _handleSubmitKyc,
    );

    // GET /user/profile - Includes KYC status (legacy endpoint)
    interceptor.register(
      method: 'GET',
      path: '/user/profile',
      handler: _handleGetProfile,
    );
  }

  static Future<MockResponse> _handleSubmitKyc(RequestOptions options) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate auto-verification process
    KycMockState.kycStatus = 'pending_verification';
    KycMockState.rejectionReason = null;

    // Simulate auto-approval after a delay (80% success rate)
    Future.delayed(const Duration(seconds: 5), () {
      if (DateTime.now().second % 5 == 0) {
        KycMockState.kycStatus = 'manual_review';
      } else {
        KycMockState.kycStatus = 'auto_approved';
      }
    });

    return MockResponse.success({
      'id': 'kyc_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending_verification',
      'message': 'KYC submitted successfully. Verification in progress.',
    });
  }

  static Future<MockResponse> _handleGetStatus(RequestOptions options) async {
    return MockResponse.success({
      'status': KycMockState.kycStatus,
      'score': KycMockState.kycStatus == 'auto_approved' ||
               KycMockState.kycStatus == 'approved' ? 92 : null,
      'submittedAt': KycMockState.kycStatus != 'none' &&
                     KycMockState.kycStatus != 'documents_pending'
          ? DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()
          : null,
      'approvedAt': KycMockState.kycStatus == 'auto_approved' ||
                    KycMockState.kycStatus == 'approved'
          ? DateTime.now().toIso8601String()
          : null,
      'rejectedAt': KycMockState.kycStatus == 'rejected'
          ? DateTime.now().toIso8601String()
          : null,
      'rejectionReason': KycMockState.rejectionReason,
      'canResubmit': KycMockState.kycStatus == 'rejected',
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
  // Backend KYC status values:
  // - 'none': No KYC submission yet
  // - 'documents_pending': User needs to upload documents
  // - 'pending_verification': Documents submitted, awaiting verification
  // - 'auto_approved': Automatically approved by system
  // - 'approved': Manually approved by admin
  // - 'manual_review': Requires manual review
  // - 'rejected': KYC rejected
  static String kycStatus = 'none';
  static String? rejectionReason;

  static void reset() {
    kycStatus = 'none';
    rejectionReason = null;
  }

  /// Simulate KYC approval (for testing)
  static void approve() {
    kycStatus = 'approved';
    rejectionReason = null;
  }

  /// Simulate auto-approval (for testing)
  static void autoApprove() {
    kycStatus = 'auto_approved';
    rejectionReason = null;
  }

  /// Simulate KYC rejection (for testing)
  static void reject(String reason) {
    kycStatus = 'rejected';
    rejectionReason = reason;
  }

  /// Simulate manual review needed (for testing)
  static void requireManualReview() {
    kycStatus = 'manual_review';
    rejectionReason = null;
  }

  /// Set pending verification state
  static void setPendingVerification() {
    kycStatus = 'pending_verification';
    rejectionReason = null;
  }

  /// Set documents pending state
  static void setDocumentsPending() {
    kycStatus = 'documents_pending';
    rejectionReason = null;
  }
}
