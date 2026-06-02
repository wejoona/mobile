import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';

/// Beneficiaries Service - mirrors backend BeneficiariesController
class BeneficiariesService {
  final Dio _dio;

  BeneficiariesService(this._dio);

  /// GET /api/v1/beneficiaries
  Future<List<Beneficiary>> getBeneficiaries({
    bool? favorites,
    bool? recent,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (favorites != null) queryParams['favorites'] = favorites;
      if (recent != null) queryParams['recent'] = recent;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        '/beneficiaries',
        queryParameters: queryParams,
      );

      return _beneficiaryListFromResponse(
        response.data,
      ).map((json) => Beneficiary.fromJson(_asStringMap(json))).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/beneficiaries/:id
  Future<Beneficiary> getBeneficiary(String id) async {
    try {
      final response = await _dio.get('/beneficiaries/$id');
      return Beneficiary.fromJson(_beneficiaryJsonFromResponse(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/beneficiaries
  Future<Beneficiary> createBeneficiary(
    CreateBeneficiaryRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/beneficiaries',
        data: request.toJson(),
      );
      return Beneficiary.fromJson(_beneficiaryJsonFromResponse(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/beneficiaries/:id
  Future<Beneficiary> updateBeneficiary(
    String id,
    UpdateBeneficiaryRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/beneficiaries/$id',
        data: request.toJson(),
      );
      return Beneficiary.fromJson(_beneficiaryJsonFromResponse(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/beneficiaries/:id
  Future<void> deleteBeneficiary(String id) async {
    try {
      await _dio.delete('/beneficiaries/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/beneficiaries/:id/favorite
  Future<Beneficiary> toggleFavorite(String id) async {
    try {
      final response = await _dio.post('/beneficiaries/$id/favorite');
      return Beneficiary.fromJson(_beneficiaryJsonFromResponse(response.data));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<Object?> _beneficiaryListFromResponse(Object? data) {
    if (data is List) return data;
    if (data is Map) {
      final wrapped = data['beneficiaries'] ?? data['data'] ?? data['items'];
      if (wrapped is List) return wrapped;
    }
    return const [];
  }

  Map<String, dynamic> _beneficiaryJsonFromResponse(Object? data) {
    final value = data is Map
        ? (data['beneficiary'] ?? data['data'] ?? data)
        : data;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Invalid beneficiary response');
  }

  Map<String, dynamic> _asStringMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Invalid beneficiary response');
  }

  Exception _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return Exception(message);
      }
      if (message is List && message.isNotEmpty) {
        return Exception(message.join(', '));
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return Exception(error);
      }
      return Exception('Failed to process beneficiary request');
    }
    return Exception('Network error: ${e.message}');
  }
}

/// Beneficiaries Service Provider
final beneficiariesServiceProvider = Provider<BeneficiariesService>((ref) {
  final dio = ref.watch(dioProvider);
  return BeneficiariesService(dio);
});
