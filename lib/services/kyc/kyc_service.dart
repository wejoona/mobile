import 'package:dio/dio.dart';
import 'dart:io';
import '../../features/kyc/models/kyc_status.dart';

class KycService {
  final Dio _dio;

  KycService(this._dio);

  Future<void> submitKyc({
    required List<String> documentPaths,
    required String selfiePath,
    required String documentType,
  }) async {
    final formData = FormData();

    // Add document images
    for (int i = 0; i < documentPaths.length; i++) {
      final file = File(documentPaths[i]);
      final fileName = 'document_${i + 1}.jpg';
      formData.files.add(MapEntry(
        'documents',
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    // Add selfie
    final selfieFile = File(selfiePath);
    formData.files.add(MapEntry(
      'selfie',
      await MultipartFile.fromFile(selfieFile.path, filename: 'selfie.jpg'),
    ));

    // Add document type
    formData.fields.add(MapEntry('documentType', documentType));

    await _dio.post('/user/kyc', data: formData);
  }

  Future<KycStatusResponse> getKycStatus() async {
    final response = await _dio.get('/user/profile');
    final kycStatus = response.data['kycStatus'] as String? ?? 'pending';
    final rejectionReason = response.data['kycRejectionReason'] as String?;

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

    await _dio.post('/user/kyc/address', data: formData);
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

    await _dio.post('/user/kyc/video', data: formData);
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

    await _dio.post('/user/kyc/additional-documents', data: formData);
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
