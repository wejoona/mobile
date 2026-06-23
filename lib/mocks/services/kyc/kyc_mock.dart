import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';

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

    // POST /kyc/documents - Upload KYC documents
    interceptor.register(
      method: 'POST',
      path: '/kyc/documents',
      handler: _handleUploadDocuments,
    );

    // POST /kyc/liveness/session - Create liveness session
    interceptor.register(
      method: 'POST',
      path: '/kyc/liveness/session',
      handler: _handleCreateLivenessSession,
    );

    // POST /kyc/liveness/challenge - Submit challenge photo
    interceptor.register(
      method: 'POST',
      path: '/kyc/liveness/challenge',
      handler: _handleSubmitLivenessChallenge,
    );

    // POST /kyc/liveness/reference-selfie - Submit reference selfie
    interceptor.register(
      method: 'POST',
      path: '/kyc/liveness/reference-selfie',
      handler: _handleSubmitReferenceSelfie,
    );

    // GET /kyc/liveness/status - Get liveness status
    interceptor.register(
      method: 'GET',
      path: '/kyc/liveness/status',
      handler: _handleGetLivenessStatus,
    );

    // POST /kyc/document/submit - Submit document verification
    interceptor.register(
      method: 'POST',
      path: '/kyc/document/submit',
      handler: _handleSubmitDocumentVerification,
    );

    // GET /kyc/verification/status - Get full verification status
    interceptor.register(
      method: 'GET',
      path: '/kyc/verification/status',
      handler: _handleGetFullVerificationStatus,
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

  static Future<MockResponse> _handleUploadDocuments(
    RequestOptions options,
  ) async {
    final data = options.data;
    final documents = <String, Map<String, dynamic>>{};

    if (data is FormData) {
      for (final file in data.files) {
        final field = file.key;
        documents[field] = {
          'key':
              'kyc/mock-user/$field-${DateTime.now().millisecondsSinceEpoch}.jpg',
          'url': 'mock://kyc/$field',
          'size': file.value.length,
        };
      }
    }

    if (documents.isEmpty) {
      return MockResponse.badRequest(
        'At least one file required: idFront, idBack, selfie, or video',
      );
    }

    return MockResponse.success({
      'message': 'Documents uploaded successfully',
      'documents': documents,
    });
  }

  static Future<MockResponse> _handleCreateLivenessSession(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'sessionToken': 'mock_liveness_${DateTime.now().millisecondsSinceEpoch}',
      'challenges': [
        {
          'id': 'blink',
          'type': 'BLINK',
          'instruction': 'Blink twice',
          'requiredCaptureMode': 'photo',
          'acceptedCaptureModes': ['photo'],
          'requiredEvidence': ['reference_selfie', 'challenge_photo'],
        },
        {
          'id': 'turn_left',
          'type': 'TURN_LEFT',
          'instruction': 'Turn your head left',
          'requiredCaptureMode': 'photo',
          'acceptedCaptureModes': ['photo'],
          'requiredEvidence': ['reference_selfie', 'challenge_photo'],
        },
      ],
      'providerCapabilities': {
        'supportedCaptureModes': ['photo'],
        'preferredCaptureMode': 'photo',
        'supportedMimeTypes': ['image/jpeg'],
        'supportedChallengeTypes': ['BLINK', 'SMILE', 'TURN_HEAD', 'NOD'],
        'requiresReferenceSelfie': true,
        'supportsOnDeviceFaceDetection': false,
      },
      'clientCapabilities': {
        'supportedCaptureModes': ['photo'],
        'preferredCaptureMode': 'photo',
        'supportedMimeTypes': ['image/jpeg'],
        'supportsOnDeviceFaceDetection': false,
        'supportsReferenceSelfie': true,
      },
      'negotiatedCapabilities': {
        'supportedCaptureModes': ['photo'],
        'preferredCaptureMode': 'photo',
        'supportedMimeTypes': ['image/jpeg'],
        'supportsOnDeviceFaceDetection': false,
        'supportsReferenceSelfie': true,
      },
      'requiredCaptureMode': 'photo',
      'acceptedCaptureModes': ['photo'],
      'requiredEvidence': ['reference_selfie', 'challenge_photo'],
      'evidencePolicy': {
        'captureModes': {
          'providerSupported': ['photo'],
          'clientSupported': ['photo'],
          'accepted': ['photo'],
          'required': 'photo',
        },
        'supportedChallengeTypes': ['BLINK', 'SMILE', 'TURN_HEAD', 'NOD'],
        'supportedMimeTypes': ['image/jpeg'],
        'maxVideoDurationSeconds': null,
        'requiresReferenceSelfie': true,
        'requiresOnDeviceFaceDetection': false,
        'faceMatchSources': [
          'id_document_face',
          'current_profile_photo',
          'reference_selfie',
          'liveness_challenge_media',
        ],
        'manualReviewOnProviderUnavailable': true,
      },
    });
  }

  static Future<MockResponse> _handleSubmitLivenessChallenge(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'sessionToken': 'mock_liveness_session',
      'status': 'PASSED',
      'challengesCompleted': 2,
      'challengesTotal': 2,
      'isAlive': true,
      'confidence': 91,
      'result': {
        'isAlive': true,
        'confidence': 91,
        'antiSpoofScore': 94,
        'faceMatchScore': 90,
      },
      'evidence': {
        'kind': 'challenge_photo',
        'challengeId': 'turn_left',
        'captureMode': 'photo',
        'mediaType': 'photo',
        'mimeType': 'image/jpeg',
        'byteSize': 144128,
        'provider': 'verifyhq',
        'storage': 'provider_session',
        'sessionTokenRef': '***session',
        'submittedAt': DateTime.now().toIso8601String(),
        'reviewUsage': ['face_match', 'anti_spoof', 'liveness_challenge'],
      },
    });
  }

  static Future<MockResponse> _handleSubmitReferenceSelfie(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'id': 'selfie_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'SUBMITTED',
      'evidence': {
        'kind': 'reference_selfie',
        'challengeId': null,
        'captureMode': 'photo',
        'mediaType': 'photo',
        'mimeType': 'image/jpeg',
        'byteSize': 131072,
        'provider': 'verifyhq',
        'storage': 'provider_session',
        'sessionTokenRef': '***session',
        'submittedAt': DateTime.now().toIso8601String(),
        'reviewUsage': ['face_match', 'anti_spoof', 'reference_selfie'],
      },
    });
  }

  static Future<MockResponse> _handleGetLivenessStatus(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'id': 'live_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'PASSED',
      'isAlive': true,
      'confidence': 0.91,
    });
  }

  static Future<MockResponse> _handleSubmitDocumentVerification(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'id': 'doc_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'PENDING',
      'extractedData': <String, dynamic>{},
    });
  }

  static Future<MockResponse> _handleGetFullVerificationStatus(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'kyc': {
        'status': KycMockState.kycStatus,
        'rejectionReason': KycMockState.rejectionReason,
      },
      'verification': {
        'overallStatus': 'PENDING',
        'documentVerificationId': 'doc_mock',
        'livenessCheckId': 'live_mock',
        'faceMatchScore': 91,
        'tier': 'BASIC',
      },
    });
  }

  static Future<MockResponse> _handleGetStatus(RequestOptions options) async {
    return MockResponse.success({
      'status': KycMockState.kycStatus,
      'score':
          KycMockState.kycStatus == 'auto_approved' ||
              KycMockState.kycStatus == 'approved'
          ? 92
          : null,
      'submittedAt':
          KycMockState.kycStatus != 'none' &&
              KycMockState.kycStatus != 'documents_pending'
          ? DateTime.now()
                .subtract(const Duration(minutes: 5))
                .toIso8601String()
          : null,
      'approvedAt':
          KycMockState.kycStatus == 'auto_approved' ||
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
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
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
  static const String initialStatus = String.fromEnvironment(
    'MOCK_KYC_STATUS',
    defaultValue: 'none',
  );

  static String kycStatus = _normalizeStatus(initialStatus);
  static String? rejectionReason;

  static void reset() {
    kycStatus = _normalizeStatus(initialStatus);
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

  /// Set KYC status directly (for testing convenience)
  /// Valid values: 'none', 'documents_pending', 'pending_verification',
  ///               'auto_approved', 'approved', 'verified', 'manual_review', 'rejected'
  static void setStatus(String status) {
    kycStatus = _normalizeStatus(status);
    if (status != 'rejected') {
      rejectionReason = null;
    }
  }

  static String _normalizeStatus(String status) {
    return status == 'verified' ? 'approved' : status;
  }
}
