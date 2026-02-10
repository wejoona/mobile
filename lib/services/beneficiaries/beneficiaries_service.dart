import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../features/beneficiaries/models/beneficiary.dart';

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

      return (response.data['beneficiaries'] as List)
          .map((json) => Beneficiary.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/beneficiaries/:id
  Future<Beneficiary> getBeneficiary(String id) async {
    try {
      final response = await _dio.get('/beneficiaries/$id');
      return Beneficiary.fromJson(response.data as Map<String, dynamic>);
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
      return Beneficiary.fromJson(response.data as Map<String, dynamic>);
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
      return Beneficiary.fromJson(response.data as Map<String, dynamic>);
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
      return Beneficiary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final message = e.response!.data['message'] as String?;
      return Exception(message ?? 'Failed to process beneficiary request');
    }
    return Exception('Network error: ${e.message}');
  }
}

/// Beneficiaries Service Provider
final beneficiariesServiceProvider = Provider<BeneficiariesService>((ref) {
  final dio = ref.watch(dioProvider);
  return BeneficiariesService(dio);
});
