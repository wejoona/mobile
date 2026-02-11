import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';
import 'image_quality_checker.dart';

class KycService {
  final Dio _dio;

  KycService(this._dio);

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
      idNumber: idNumber ?? 'PENDING',
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
        final compressedBytes = await ImageQualityChecker.compressImage(documentPaths[0]);
        debugPrint('[KycService] idFront compressed: ${compressedBytes.length} bytes');
        formData.files.add(MapEntry(
          'idFront',
          MultipartFile.fromBytes(compressedBytes, filename: 'id_front.jpg'),
        ));
      } catch (e) {
        debugPrint('[KycService] idFront compression failed: $e');
        formData.files.add(MapEntry(
          'idFront',
          await MultipartFile.fromFile(documentPaths[0], filename: 'id_front.jpg'),
        ));
      }
    }

    // Add ID back (second document or same as front if only one)
    final backPath = documentPaths.length > 1 ? documentPaths[1] : documentPaths[0];
    try {
      final compressedBytes = await ImageQualityChecker.compressImage(backPath);
      debugPrint('[KycService] idBack compressed: ${compressedBytes.length} bytes');
      formData.files.add(MapEntry(
        'idBack',
        MultipartFile.fromBytes(compressedBytes, filename: 'id_back.jpg'),
      ));
    } catch (e) {
      debugPrint('[KycService] idBack compression failed: $e');
      formData.files.add(MapEntry(
        'idBack',
        await MultipartFile.fromFile(backPath, filename: 'id_back.jpg'),
      ));
    }

    // Add selfie (compressed)
    try {
      final compressedSelfie = await ImageQualityChecker.compressImage(selfiePath);
      debugPrint('[KycService] selfie compressed: ${compressedSelfie.length} bytes');
      formData.files.add(MapEntry(
        'selfie',
        MultipartFile.fromBytes(compressedSelfie, filename: 'selfie.jpg'),
      ));
    } catch (e) {
      debugPrint('[KycService] selfie compression failed: $e');
      formData.files.add(MapEntry(
        'selfie',
        await MultipartFile.fromFile(selfiePath, filename: 'selfie.jpg'),
      ));
    }

    // Upload to /kyc/documents
    final response = await _dio.post('/kyc/documents', data: formData);

    // Extract S3 keys from response
    final documents = response.data['documents'] as Map<String, dynamic>;
    return {
      'idFront': documents['idFront']['key'] as String,
      'idBack': documents['idBack']['key'] as String,
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

    await _dio.post('/kyc/submit', data: {
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
    });
  }

  Future<KycStatusResponse> getKycStatus() async {
    final response = await _dio.get('/kyc/status');
    final kycStatus = response.data['status'] as String? ?? 'pending';
    final rejectionReason = response.data['rejectionReason'] as String?;

    return KycStatusResponse(
      status: KycStatus.fromString(kycStatus),
      rejectionReason: rejectionReason,
    );
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
    final formData = FormData();

    // Add address fields
    formData.fields.addAll([
      MapEntry('addressLine1', addressLine1),
      MapEntry('addressLine2', addressLine2),
      MapEntry('city', city),
      MapEntry('state', state),
      MapEntry('postalCode', postalCode),
      MapEntry('country', country),
      MapEntry('documentType', documentType),
    ]);

    // Add document
    final file = File(documentPath);
    formData.files.add(MapEntry(
      'document',
      await MultipartFile.fromFile(file.path, filename: 'address_proof.jpg'),
    ));

    await _dio.post('/kyc/address', data: formData);
  }

  Future<void> submitVideoVerification({
    required String videoPath,
  }) async {
    final formData = FormData();

    // Add video file
    final file = File(videoPath);
    formData.files.add(MapEntry(
      'video',
      await MultipartFile.fromFile(file.path, filename: 'verification_video.mp4'),
    ));

    await _dio.post('/kyc/video', data: formData);
  }

  // ==========================================
  // Verification endpoints (VerifyHQ-backed)
  // ==========================================

  /// Create a liveness verification session
  /// Returns sessionToken + challenge info
  Future<LivenessSessionResponse> createLivenessSession() async {
    final response = await _dio.post('/kyc/liveness/session');
    return LivenessSessionResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Submit liveness check with video + selfie S3 keys
  Future<LivenessSubmitResponse> submitLiveness({
    required String sessionToken,
    required String videoKey,
    required String selfieKey,
  }) async {
    final response = await _dio.post('/kyc/liveness/submit', data: {
      'sessionToken': sessionToken,
      'videoKey': videoKey,
      'selfieKey': selfieKey,
    });
    return LivenessSubmitResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get liveness verification status for current user
  Future<LivenessSubmitResponse?> getLivenessStatus() async {
    final response = await _dio.get('/kyc/liveness/status');
    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'NOT_STARTED') return null;
    return LivenessSubmitResponse.fromJson(data);
  }

  /// Submit document for verification with S3 keys
  Future<DocumentSubmitResponse> submitDocumentVerification({
    required String docType,
    required String frontImageKey,
    String? backImageKey,
  }) async {
    final response = await _dio.post('/kyc/document/submit', data: {
      'docType': docType,
      'frontImageKey': frontImageKey,
      if (backImageKey != null) 'backImageKey': backImageKey,
    });
    return DocumentSubmitResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get full KYC verification status (doc + liveness + overall)
  Future<FullVerificationStatus> getVerificationStatus() async {
    final response = await _dio.get('/kyc/verification/status');
    return FullVerificationStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// Upload a file and return its S3 key
  /// Uses the existing /kyc/documents endpoint with a single file
  Future<String> uploadFileForVerification(String filePath, String fieldName) async {
    final formData = FormData();
    try {
      final compressedBytes = await ImageQualityChecker.compressImage(filePath);
      debugPrint('[KycService] $fieldName compressed: ${compressedBytes.length} bytes');
      formData.files.add(MapEntry(
        fieldName,
        MultipartFile.fromBytes(compressedBytes, filename: '$fieldName.jpg'),
      ));
    } catch (e) {
      debugPrint('[KycService] $fieldName compression failed: $e');
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(filePath, filename: '$fieldName.jpg'),
      ));
    }

    final response = await _dio.post('/kyc/documents', data: formData);
    final responseData = response.data as Map<String, dynamic>;
    final documents = responseData['documents'] as Map<String, dynamic>;
    final fieldData = documents[fieldName] as Map<String, dynamic>;
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
    final formData = FormData();

    // Add form fields
    formData.fields.addAll([
      MapEntry('occupation', occupation),
      MapEntry('employer', employer),
      MapEntry('monthlyIncome', monthlyIncome),
      MapEntry('sourceOfFunds', sourceOfFunds),
      MapEntry('sourceDetails', sourceDetails),
    ]);

    // Add supporting documents
    for (int i = 0; i < supportingDocuments.length; i++) {
      final file = File(supportingDocuments[i]);
      final fileName = 'document_${i + 1}.jpg';
      formData.files.add(MapEntry(
        'supportingDocuments',
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    await _dio.post('/kyc/additional-documents', data: formData);
  }
}

class KycStatusResponse {
  final KycStatus status;
  final String? rejectionReason;

  const KycStatusResponse({
    required this.status,
    this.rejectionReason,
  });
}

// ==========================================
// Verification DTOs (for /kyc/liveness/* and /kyc/document/* and /kyc/verification/*)
// ==========================================

class LivenessSessionResponse {
  final String sessionToken;
  final String? challengeType;
  final Map<String, dynamic>? challengeData;

  const LivenessSessionResponse({
    required this.sessionToken,
    this.challengeType,
    this.challengeData,
  });

  factory LivenessSessionResponse.fromJson(Map<String, dynamic> json) {
    return LivenessSessionResponse(
      sessionToken: json['sessionToken'] as String,
      challengeType: json['challengeType'] as String?,
      challengeData: json['challengeData'] as Map<String, dynamic>?,
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

  const FullVerificationStatus({
    required this.kyc,
    this.verification,
  });

  factory FullVerificationStatus.fromJson(Map<String, dynamic> json) {
    final kycData = json['kyc'] as Map<String, dynamic>? ?? {};
    final verifyData = json['verification'] as Map<String, dynamic>?;

    return FullVerificationStatus(
      kyc: KycStatusResponse(
        status: KycStatus.fromString(kycData['status'] as String? ?? 'pending'),
        rejectionReason: kycData['rejectionReason'] as String?,
      ),
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
