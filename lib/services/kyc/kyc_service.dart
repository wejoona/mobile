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
}

class KycStatusResponse {
  final KycStatus status;
  final String? rejectionReason;

  const KycStatusResponse({
    required this.status,
    this.rejectionReason,
  });
}
