import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/beneficiaries/beneficiaries_service.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';

/// Beneficiaries Repository
///
/// Handles all beneficiary-related API calls
class BeneficiariesRepository {
  final BeneficiariesService _service;

  BeneficiariesRepository(this._service);

  /// Get all beneficiaries
  ///
  /// Optional filters:
  /// - [favorites]: Only return favorites
  /// - [recent]: Only return recently used
  /// - [type]: Filter by account type
  Future<List<Beneficiary>> getBeneficiaries({
    bool? favorites,
    bool? recent,
    String? type,
  }) async {
    return _service.getBeneficiaries(
      favorites: favorites,
      recent: recent,
      type: type,
    );
  }

  /// Get a single beneficiary by ID
  Future<Beneficiary> getBeneficiary(String id) async {
    return _service.getBeneficiary(id);
  }

  /// Create a new beneficiary
  Future<Beneficiary> createBeneficiary(
    CreateBeneficiaryRequest request,
  ) async {
    return _service.createBeneficiary(request);
  }

  /// Update an existing beneficiary
  Future<Beneficiary> updateBeneficiary(
    String id,
    UpdateBeneficiaryRequest request,
  ) async {
    return _service.updateBeneficiary(id, request);
  }

  /// Delete a beneficiary
  Future<void> deleteBeneficiary(String id) async {
    return _service.deleteBeneficiary(id);
  }

  /// Toggle favorite status
  Future<Beneficiary> toggleFavorite(String id) async {
    return _service.toggleFavorite(id);
  }
}

/// Beneficiaries Repository Provider
final beneficiariesRepositoryProvider = Provider<BeneficiariesRepository>((ref) {
  final service = ref.watch(beneficiariesServiceProvider);
  return BeneficiariesRepository(service);
});
