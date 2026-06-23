import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/kyc/image_quality_checker.dart';

class KycService {
  KycService(this._dio);

  final Dio _dio;

  static const List<String> kycRequiredConsentTypes = [
    'kyc_data_processing',
    'kyc_data_sharing',
    'privacy_policy',
    'terms_of_service',
    'aml_screening',
  ];

  Future<bool> hasRequiredKycConsents() async {
    final response = await _dio.get('/consent/status');
    final data = apiResponsePayload(response.data);
    final consents = data['consents'];
    if (data['kycReady'] == true) {
      return true;
    }
    if (consents is! List) {
      return false;
    }

    final granted = <String>{};
    for (final item in consents) {
      if (item is Map && item['granted'] == true) {
        final consentType = item['consentType']?.toString();
        if (consentType != null) {
          granted.add(consentType);
        }
      }
    }

    return kycRequiredConsentTypes.every(granted.contains);
  }

  Future<void> grantRequiredKycConsents({
    String version = 'korido-mobile-kyc-v1',
  }) async {
    await Future.wait(
      kycRequiredConsentTypes.map(
        (consentType) => _dio.post(
          '/consent/grant',
          data: {'consentType': consentType, 'version': version},
        ),
      ),
    );
  }

  /// Submit KYC following the two-step backend flow:
  /// 1. Upload documents to /kyc/documents → get S3 keys
  /// 2. Submit KYC to /kyc/submit with personal info + S3 keys
  Future<void> submitKyc({
    required List<String> documentPaths,
    required String selfiePath,
    required String documentType,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String country,
    String? idNumber,
  }) async {
    final trimmedIdNumber = idNumber?.trim() ?? '';
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      throw ArgumentError('firstName and lastName are required');
    }
    if (country.trim().isEmpty) {
      throw ArgumentError('country is required');
    }
    if (documentType.trim().isEmpty) {
      throw ArgumentError('documentType is required');
    }
    if (trimmedIdNumber.isEmpty) {
      throw ArgumentError('documentNumber is required');
    }
    if (documentPaths.isEmpty) {
      throw ArgumentError('At least one ID document image is required');
    }
    if (selfiePath.trim().isEmpty) {
      throw ArgumentError('selfie is required');
    }

    // Step 1: Upload documents to /kyc/documents
    debugPrint('[KycService] Step 1: Uploading documents...');
    final documentKeys = await _uploadDocuments(
      documentPaths: documentPaths,
      selfiePath: selfiePath,
    );

    // Step 2: Submit KYC with personal info + S3 keys
    debugPrint('[KycService] Step 2: Submitting KYC...');
    await _submitKycData(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      country: country,
      idType: documentType,
      idNumber: trimmedIdNumber,
      idFrontKey: documentKeys['idFront']!,
      idBackKey: documentKeys['idBack']!,
      selfieKey: documentKeys['selfie']!,
    );

    debugPrint('[KycService] KYC submission complete');
  }

  /// Upload documents to /kyc/documents endpoint
  /// Returns map of S3 keys: {idFront, idBack, selfie}
  Future<Map<String, String>> _uploadDocuments({
    required List<String> documentPaths,
    required String selfiePath,
  }) async {
    final formData = FormData();

    // Add ID front (first document, compressed)
    if (documentPaths.isNotEmpty) {
      try {
        final compressedBytes = await ImageQualityChecker.compressImage(
          documentPaths[0],
        );
        debugPrint(
          '[KycService] idFront compressed: ${compressedBytes.length} bytes',
        );
        formData.files.add(
          MapEntry(
            'idFront',
            MultipartFile.fromBytes(compressedBytes, filename: 'id_front.jpg'),
          ),
        );
      } catch (e) {
        debugPrint('[KycService] idFront compression failed: $e');
        formData.files.add(
          MapEntry(
            'idFront',
            await MultipartFile.fromFile(
              documentPaths[0],
              filename: 'id_front.jpg',
            ),
          ),
        );
      }
    }

    // Add ID back (second document or same as front if only one)
    final backPath = documentPaths.length > 1
        ? documentPaths[1]
        : documentPaths[0];
    try {
      final compressedBytes = await ImageQualityChecker.compressImage(backPath);
      debugPrint(
        '[KycService] idBack compressed: ${compressedBytes.length} bytes',
      );
      formData.files.add(
        MapEntry(
          'idBack',
          MultipartFile.fromBytes(compressedBytes, filename: 'id_back.jpg'),
        ),
      );
    } catch (e) {
      debugPrint('[KycService] idBack compression failed: $e');
      formData.files.add(
        MapEntry(
          'idBack',
          await MultipartFile.fromFile(backPath, filename: 'id_back.jpg'),
        ),
      );
    }

    // Add selfie (compressed)
    try {
      final compressedSelfie = await ImageQualityChecker.compressImage(
        selfiePath,
      );
      debugPrint(
        '[KycService] selfie compressed: ${compressedSelfie.length} bytes',
      );
      formData.files.add(
        MapEntry(
          'selfie',
          MultipartFile.fromBytes(compressedSelfie, filename: 'selfie.jpg'),
        ),
      );
    } catch (e) {
      debugPrint('[KycService] selfie compression failed: $e');
      formData.files.add(
        MapEntry(
          'selfie',
          await MultipartFile.fromFile(selfiePath, filename: 'selfie.jpg'),
        ),
      );
    }

    // Upload to /kyc/documents
    final response = await _dio.post(ApiEndpoints.kycUpload, data: formData);

    final data = apiResponsePayload(response.data);
    final documents = data['documents'] as Map<String, dynamic>;
    return {
      // ignore: avoid_dynamic_calls
      'idFront': documents['idFront']['key'] as String,
      // ignore: avoid_dynamic_calls
      'idBack': documents['idBack']['key'] as String,
      // ignore: avoid_dynamic_calls
      'selfie': documents['selfie']['key'] as String,
    };
  }

  /// Submit KYC data to /kyc/submit endpoint
  Future<void> _submitKycData({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String country,
    required String idType,
    required String idNumber,
    required String idFrontKey,
    required String idBackKey,
    required String selfieKey,
    String? idExpiryDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    await _dio.post(
      ApiEndpoints.kycSubmit,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateFormat.format(dateOfBirth),
        'country': country,
        'idType': idType,
        'idNumber': idNumber,
        'idFrontKey': idFrontKey,
        'idBackKey': idBackKey,
        'selfieKey': selfieKey,
        if (idExpiryDate != null) 'idExpiryDate': idExpiryDate,
      },
    );
  }

  Future<KycStatusResponse> getKycStatus({bool forceRefresh = false}) async {
    final response = await _dio.get(
      ApiEndpoints.kycStatus,
      options: forceRefresh ? Options(extra: const {'skipCache': true}) : null,
    );
    final data = apiResponsePayload(response.data);
    final kycStatus = data['status'] as String? ?? 'pending';
    final rejectionReason = data['rejectionReason'] as String?;

    return KycStatusResponse.fromJson(
      data,
      fallbackStatus: kycStatus,
    ).copyWith(rejectionReason: rejectionReason);
  }

  Future<KycManualReviewResponse> routeToManualReview({
    required String reason,
    required String featureReason,
    String? provider,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.kycManualReview,
      data: {
        'reason': reason,
        'featureReason': featureReason,
        if (provider != null) 'provider': provider,
        if (metadata != null) 'metadata': metadata,
      },
    );

    return KycManualReviewResponse.fromJson(apiResponsePayload(response.data));
  }

  Future<void> submitAddressVerification({
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String documentType,
    required String documentPath,
  }) async {
    await uploadDocument(type: 'idBack', filePath: documentPath);
  }

  Future<void> submitVideoVerification({required String videoPath}) async {
    final formData = FormData();

    // Add video file
    final file = File(videoPath);
    formData.files.add(
      MapEntry(
        'video',
        await MultipartFile.fromFile(
          file.path,
          filename: 'verification_video.mp4',
        ),
      ),
    );

    await _dio.post(ApiEndpoints.kycUpload, data: formData);
  }

  // ==========================================
  // Verification endpoints (VerifyHQ-backed)
  // ==========================================

  /// Create a liveness verification session
  /// Returns sessionToken + challenge info
  Future<LivenessSessionResponse> createLivenessSession() async {
    final response = await _dio.post(
      ApiEndpoints.kycLivenessSession,
      data: {
        'capabilities': {
          'supportedCaptureModes': ['photo'],
          'preferredCaptureMode': 'photo',
          'supportedMimeTypes': ['image/jpeg'],
          'maxVideoDurationSeconds': null,
          'supportsOnDeviceFaceDetection': false,
          'supportsReferenceSelfie': true,
        },
      },
    );
    return LivenessSessionResponse.fromJson(apiResponsePayload(response.data));
  }

  /// Submit liveness check with video + selfie S3 keys
  Future<LivenessSubmitResponse> submitLiveness({
    required String sessionToken,
    required String videoKey,
    required String selfieKey,
  }) async {
    throw UnsupportedError(
      'Use the challenge-based liveness flow: createLivenessSession, '
      'submit each challenge to /kyc/liveness/challenge, then check status.',
    );
  }

  /// Get liveness verification status for current user
  Future<LivenessSubmitResponse?> getLivenessStatus() async {
    final response = await _dio.get(ApiEndpoints.kycLivenessStatus);
    final data = apiResponsePayload(response.data);
    if (data['status'] == 'NOT_STARTED') return null;
    return LivenessSubmitResponse.fromJson(data);
  }

  /// Submit document for verification with S3 keys
  Future<DocumentSubmitResponse> submitDocumentVerification({
    required String docType,
    required String frontImageKey,
    String? backImageKey,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.kycDocumentSubmit,
      data: {
        'docType': docType,
        'frontImageKey': frontImageKey,
        if (backImageKey != null) 'backImageKey': backImageKey,
      },
    );
    return DocumentSubmitResponse.fromJson(apiResponsePayload(response.data));
  }

  /// Get full KYC verification status (doc + liveness + overall)
  Future<FullVerificationStatus> getVerificationStatus() async {
    final response = await _dio.get(ApiEndpoints.kycVerificationStatus);
    return FullVerificationStatus.fromJson(apiResponsePayload(response.data));
  }

  /// Upload a file and return its S3 key
  /// Uses the existing /kyc/documents endpoint with a single file
  Future<String> uploadFileForVerification(
    String filePath,
    String fieldName,
  ) async {
    final documentField = _documentFieldForType(fieldName);
    final formData = FormData();
    try {
      final compressedBytes = await ImageQualityChecker.compressImage(filePath);
      debugPrint(
        '[KycService] $documentField compressed: ${compressedBytes.length} bytes',
      );
      formData.files.add(
        MapEntry(
          documentField,
          MultipartFile.fromBytes(
            compressedBytes,
            filename: '$documentField.jpg',
          ),
        ),
      );
    } catch (e) {
      debugPrint('[KycService] $documentField compression failed: $e');
      formData.files.add(
        MapEntry(
          documentField,
          await MultipartFile.fromFile(
            filePath,
            filename: '$documentField.jpg',
          ),
        ),
      );
    }

    final response = await _dio.post(ApiEndpoints.kycUpload, data: formData);
    final responseData = apiResponsePayload(response.data);
    final documents = responseData['documents'] as Map<String, dynamic>;
    final fieldData = documents[documentField] as Map<String, dynamic>;
    return fieldData['key'] as String;
  }

  Future<void> submitAdditionalDocuments({
    required String occupation,
    required String employer,
    required String monthlyIncome,
    required String sourceOfFunds,
    required String sourceDetails,
    required List<String> supportingDocuments,
  }) async {
    for (final path in supportingDocuments) {
      await uploadDocument(type: 'idBack', filePath: path);
    }
  }

  /// Submit KYC from collected form data map.
  /// All required fields must be present — no hardcoded fallbacks.
  Future<void> submitKycFromData({required Map<String, dynamic> data}) async {
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final country = data['country'] as String? ?? '';
    final dobStr = data['dateOfBirth'] as String? ?? '';
    final documentType = data['documentType'] as String? ?? '';
    final idNumber = data['documentNumber'] as String? ?? '';
    final documentPaths = (data['documentPaths'] as List<String>?) ?? [];
    final selfiePath = data['selfiePath'] as String? ?? '';

    if (firstName.isEmpty || lastName.isEmpty) {
      throw ArgumentError('firstName and lastName are required');
    }
    if (country.isEmpty) {
      throw ArgumentError('country is required');
    }
    final dob = DateTime.tryParse(dobStr);
    if (dob == null) {
      throw ArgumentError('Valid dateOfBirth is required');
    }
    if (documentType.isEmpty) {
      throw ArgumentError('documentType is required');
    }
    if (idNumber.isEmpty) {
      throw ArgumentError('documentNumber is required');
    }

    await submitKyc(
      firstName: firstName,
      lastName: lastName,
      country: country,
      dateOfBirth: dob,
      documentType: documentType,
      documentPaths: documentPaths,
      selfiePath: selfiePath,
      idNumber: idNumber,
    );
  }

  /// Upload a single document for KYC verification.
  Future<Map<String, dynamic>> uploadDocument({
    required String type,
    required String filePath,
  }) async {
    final documentField = _documentFieldForType(type);
    final formData = FormData.fromMap({
      documentField: await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(ApiEndpoints.kycUpload, data: formData);
    return apiResponsePayload(response.data);
  }

  String _documentFieldForType(String type) {
    switch (type.replaceAll('_', '').replaceAll('-', '').toLowerCase()) {
      case 'idfront':
      case 'front':
        return 'idFront';
      case 'idback':
      case 'back':
        return 'idBack';
      case 'selfie':
        return 'selfie';
      case 'video':
        return 'video';
      default:
        throw ArgumentError('Unsupported KYC document type: $type');
    }
  }

  /// Submit collected documents (used by repository).
  Future<KycStatusResponse> submitDocuments({
    required String firstName,
    required String lastName,
    required String country,
    required String dateOfBirth,
    required String documentType,
    required List<String> documentPaths,
    required String selfiePath,
    String? idNumber,
  }) async {
    await submitKyc(
      firstName: firstName,
      lastName: lastName,
      country: country,
      dateOfBirth: DateTime.tryParse(dateOfBirth) ?? DateTime(2000, 1, 1),
      documentType: documentType,
      documentPaths: documentPaths,
      selfiePath: selfiePath,
      idNumber: idNumber,
    );
    return getKycStatus(forceRefresh: true);
  }
}

class KycManualReviewResponse {
  final String id;
  final KycStatus status;
  final String message;
  final String? slaLabel;

  const KycManualReviewResponse({
    required this.id,
    required this.status,
    required this.message,
    this.slaLabel,
  });

  factory KycManualReviewResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'manual_review';
    final reviewSla = json['reviewSla'];
    return KycManualReviewResponse(
      id: json['id']?.toString() ?? '',
      status: KycStatus.fromString(rawStatus),
      message:
          json['message'] as String? ??
          'KYC submitted. Additional review required.',
      slaLabel: reviewSla is Map ? reviewSla['label']?.toString() : null,
    );
  }
}

class KycStatusResponse {
  final KycStatus status;
  final String rawStatus;
  final double? score;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final bool canResubmit;

  const KycStatusResponse({
    required this.status,
    required this.rawStatus,
    this.score,
    this.rejectionReason,
    this.submittedAt,
    this.approvedAt,
    this.canResubmit = false,
  });

  factory KycStatusResponse.fromJson(
    Map<String, dynamic> json, {
    String fallbackStatus = 'pending',
  }) {
    final rawStatus = json['status'] as String? ?? fallbackStatus;
    return KycStatusResponse(
      status: KycStatus.fromString(rawStatus),
      rawStatus: rawStatus,
      score: (json['score'] as num?)?.toDouble(),
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: _parseKycDate(json['submittedAt']),
      approvedAt: _parseKycDate(json['approvedAt']),
      canResubmit: json['canResubmit'] as bool? ?? false,
    );
  }

  KycStatusResponse copyWith({
    KycStatus? status,
    String? rawStatus,
    double? score,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? approvedAt,
    bool? canResubmit,
  }) => KycStatusResponse(
    status: status ?? this.status,
    rawStatus: rawStatus ?? this.rawStatus,
    score: score ?? this.score,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    submittedAt: submittedAt ?? this.submittedAt,
    approvedAt: approvedAt ?? this.approvedAt,
    canResubmit: canResubmit ?? this.canResubmit,
  );
}

DateTime? _parseKycDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

// ==========================================
// Verification DTOs (for /kyc/liveness/* and /kyc/document/* and /kyc/verification/*)
// ==========================================

class LivenessSessionResponse {
  final String sessionToken;
  final String? challengeType;
  final Map<String, dynamic>? challengeData;
  final List<Map<String, dynamic>> challenges;
  final String requiredCaptureMode;
  final List<String> acceptedCaptureModes;
  final List<String> requiredEvidence;
  final Map<String, dynamic>? evidencePolicy;

  const LivenessSessionResponse({
    required this.sessionToken,
    this.challengeType,
    this.challengeData,
    this.challenges = const [],
    this.requiredCaptureMode = 'photo',
    this.acceptedCaptureModes = const ['photo'],
    this.requiredEvidence = const ['reference_selfie', 'challenge_photo'],
    this.evidencePolicy,
  });

  factory LivenessSessionResponse.fromJson(Map<String, dynamic> json) {
    return LivenessSessionResponse(
      sessionToken: json['sessionToken'] as String,
      challengeType: json['challengeType'] as String?,
      challengeData: json['challengeData'] as Map<String, dynamic>?,
      challenges:
          (json['challenges'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((challenge) => Map<String, dynamic>.from(challenge))
              .toList() ??
          const [],
      requiredCaptureMode: json['requiredCaptureMode'] as String? ?? 'photo',
      acceptedCaptureModes:
          (json['acceptedCaptureModes'] as List<dynamic>?)
              ?.map((mode) => '$mode')
              .toList() ??
          const ['photo'],
      requiredEvidence:
          (json['requiredEvidence'] as List<dynamic>?)
              ?.map((evidence) => '$evidence')
              .toList() ??
          const ['reference_selfie', 'challenge_photo'],
      evidencePolicy: json['evidencePolicy'] is Map
          ? Map<String, dynamic>.from(json['evidencePolicy'] as Map)
          : null,
    );
  }
}

class LivenessSubmitResponse {
  final String id;
  final String status;
  final bool? isAlive;
  final double? confidence;

  const LivenessSubmitResponse({
    required this.id,
    required this.status,
    this.isAlive,
    this.confidence,
  });

  factory LivenessSubmitResponse.fromJson(Map<String, dynamic> json) {
    return LivenessSubmitResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      isAlive: json['isAlive'] as bool?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

class DocumentSubmitResponse {
  final String id;
  final String status;
  final Map<String, dynamic>? extractedData;

  const DocumentSubmitResponse({
    required this.id,
    required this.status,
    this.extractedData,
  });

  factory DocumentSubmitResponse.fromJson(Map<String, dynamic> json) {
    return DocumentSubmitResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      extractedData: json['extractedData'] as Map<String, dynamic>?,
    );
  }
}

class FullVerificationStatus {
  final KycStatusResponse kyc;
  final VerifyHqStatus? verification;

  const FullVerificationStatus({required this.kyc, this.verification});

  factory FullVerificationStatus.fromJson(Map<String, dynamic> json) {
    final kycData = json['kyc'] as Map<String, dynamic>? ?? {};
    final verifyData = json['verification'] as Map<String, dynamic>?;

    return FullVerificationStatus(
      kyc: KycStatusResponse.fromJson(kycData),
      verification: verifyData != null
          ? VerifyHqStatus.fromJson(verifyData)
          : null,
    );
  }
}

class VerifyHqStatus {
  final String? overallStatus;
  final String? documentVerificationId;
  final String? livenessCheckId;
  final double? faceMatchScore;
  final String? tier;

  const VerifyHqStatus({
    this.overallStatus,
    this.documentVerificationId,
    this.livenessCheckId,
    this.faceMatchScore,
    this.tier,
  });

  factory VerifyHqStatus.fromJson(Map<String, dynamic> json) {
    return VerifyHqStatus(
      overallStatus: json['overallStatus'] as String?,
      documentVerificationId: json['documentVerificationId'] as String?,
      livenessCheckId: json['livenessCheckId'] as String?,
      faceMatchScore: (json['faceMatchScore'] as num?)?.toDouble(),
      tier: json['tier'] as String?,
    );
  }
}
