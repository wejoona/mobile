import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/kyc/kyc_service.dart';
import 'package:usdc_wallet/services/service_providers.dart';

class KycRepository {
  final KycService _service;
  KycRepository(this._service);

  Future<dynamic> getKycStatus() => _service.getKycStatus();
  Future<dynamic> submitDocuments({
    String? documentType, String? documentNumber, String? documentPath,
    String? firstName, String? lastName, String? nationality,
    String? dateOfBirth, String? country, List<String>? documentPaths, String? selfiePath,
  }) => _service.submitKyc(
    firstName: firstName ?? '', lastName: lastName ?? '',
    country: country ?? 'CI', dateOfBirth: dateOfBirth ?? '',
    documentType: documentType ?? 'passport',
    documentPaths: documentPaths ?? (documentPath != null ? [documentPath] : []),
    selfiePath: selfiePath ?? '',
  );
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(ref.watch(kycServiceProvider));
});
