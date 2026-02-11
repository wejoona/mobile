import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/kyc/kyc_service.dart';
import '../../../domain/entities/kyc_profile.dart';

/// Repository for KYC operations.
class KycRepository {
  final KycService _service;

  KycRepository(this._service);

  /// Get current KYC status.
  Future<KycProfile> getKycStatus() async {
    return _service.getKycStatus();
  }

  /// Submit KYC documents.
  Future<KycProfile> submitDocuments({
    required String documentType,
    required String documentNumber,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String nationality,
  }) async {
    return _service.submitDocuments(
      documentType: documentType,
      documentNumber: documentNumber,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
    );
  }
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final service = ref.watch(kycServiceProvider);
  return KycRepository(service);
});
