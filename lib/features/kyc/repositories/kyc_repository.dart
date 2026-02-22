import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/kyc/kyc_service.dart';
import 'package:usdc_wallet/services/service_providers.dart';

class KycRepository {
  final KycService _service;
  KycRepository(this._service);

  Future<dynamic> getKycStatus() => _service.getKycStatus();

  /// Submit documents for KYC verification.
  /// All required fields must be provided — no hardcoded fallbacks.
  Future<dynamic> submitDocuments({
    required String firstName,
    required String lastName,
    required String country,
    required String dateOfBirth,
    required String documentType,
    String? documentNumber,
    String? documentPath,
    List<String>? documentPaths,
    String? selfiePath,
  }) {
    if (firstName.isEmpty || lastName.isEmpty) {
      throw ArgumentError('firstName and lastName are required for KYC submission');
    }
    if (country.isEmpty) {
      throw ArgumentError('country is required for KYC submission');
    }
    if (documentType.isEmpty) {
      throw ArgumentError('documentType is required for KYC submission');
    }
    final parsedDob = DateTime.tryParse(dateOfBirth);
    if (parsedDob == null) {
      throw ArgumentError('Valid dateOfBirth is required for KYC submission');
    }
    final paths = documentPaths ?? (documentPath != null ? [documentPath] : []);
    if (paths.isEmpty) {
      throw ArgumentError('At least one document path is required for KYC submission');
    }

    return _service.submitKyc(
      firstName: firstName,
      lastName: lastName,
      country: country,
      dateOfBirth: parsedDob,
      documentType: documentType,
      documentPaths: paths,
      selfiePath: selfiePath ?? '',
      idNumber: documentNumber,
    );
  }
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(ref.watch(kycServiceProvider));
});
