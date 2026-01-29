import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/whitelisted_address.dart';

/// Whitelisted Address Service - manages trusted withdrawal addresses
class WhitelistedAddressService {
  final Dio _dio;

  WhitelistedAddressService(this._dio);

  /// Get all whitelisted addresses
  Future<List<WhitelistedAddress>> getAddresses() async {
    final response = await _dio.get('/security/addresses');
    final data = response.data as Map<String, dynamic>;
    final addresses = data['addresses'] as List;
    return addresses
        .map((a) => WhitelistedAddress.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  /// Get active (verified) whitelisted addresses
  Future<List<WhitelistedAddress>> getActiveAddresses() async {
    final response = await _dio.get('/security/addresses/active');
    final data = response.data as Map<String, dynamic>;
    final addresses = data['addresses'] as List;
    return addresses
        .map((a) => WhitelistedAddress.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  /// Add a new address to whitelist
  Future<WhitelistedAddress> addAddress({
    required String address,
    required String label,
    String? addressType,
    String? network,
  }) async {
    final response = await _dio.post('/security/addresses', data: {
      'address': address,
      'label': label,
      if (addressType != null) 'addressType': addressType,
      if (network != null) 'network': network,
    });
    return WhitelistedAddress.fromJson(response.data as Map<String, dynamic>);
  }

  /// Verify a whitelisted address with PIN
  Future<WhitelistedAddress> verifyAddress({
    required String addressId,
    required String pin,
  }) async {
    final response = await _dio.post('/security/addresses/$addressId/verify', data: {
      'pin': pin,
    });
    return WhitelistedAddress.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update address label
  Future<WhitelistedAddress> updateAddress({
    required String addressId,
    required String label,
  }) async {
    final response = await _dio.put('/security/addresses/$addressId', data: {
      'label': label,
    });
    return WhitelistedAddress.fromJson(response.data as Map<String, dynamic>);
  }

  /// Revoke a whitelisted address
  Future<void> revokeAddress(String addressId) async {
    await _dio.post('/security/addresses/$addressId/revoke');
  }

  /// Delete a whitelisted address
  Future<void> deleteAddress(String addressId) async {
    await _dio.delete('/security/addresses/$addressId');
  }

  /// Check if an address is whitelisted and what restrictions apply
  Future<AddressCheckResult> checkAddress(String address) async {
    final response = await _dio.get('/security/addresses/check', queryParameters: {
      'address': address,
    });
    return AddressCheckResult.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Whitelisted Address Service Provider
final whitelistedAddressServiceProvider = Provider<WhitelistedAddressService>((ref) {
  return WhitelistedAddressService(ref.watch(dioProvider));
});

/// All Whitelisted Addresses Provider
final whitelistedAddressesProvider =
    FutureProvider.autoDispose<List<WhitelistedAddress>>((ref) async {
  final service = ref.watch(whitelistedAddressServiceProvider);
  return service.getAddresses();
});

/// Active Whitelisted Addresses Provider
final activeWhitelistedAddressesProvider =
    FutureProvider.autoDispose<List<WhitelistedAddress>>((ref) async {
  final service = ref.watch(whitelistedAddressServiceProvider);
  return service.getActiveAddresses();
});

/// Address Check Provider - checks if specific address is whitelisted
final addressCheckProvider = FutureProvider.autoDispose
    .family<AddressCheckResult, String>((ref, address) async {
  final service = ref.watch(whitelistedAddressServiceProvider);
  return service.checkAddress(address);
});
