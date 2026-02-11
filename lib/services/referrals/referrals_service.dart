import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Referrals Service - mirrors backend ReferralController
class ReferralsService {
  final Dio _dio;

  ReferralsService(this._dio);

  /// GET /referrals
  Future<Map<String, dynamic>> getReferralInfo() async {
    final response = await _dio.get('/referrals');
    return response.data as Map<String, dynamic>;
  }

  /// GET /referrals/code
  Future<String> getReferralCode() async {
    final response = await _dio.get('/referrals/code');
    return response.data['code'] as String;
  }

  /// POST /referrals/apply
  Future<Map<String, dynamic>> applyReferralCode(String code) async {
    final response = await _dio.post('/referrals/apply', data: {'code': code});
    return response.data as Map<String, dynamic>;
  }

  /// GET /referrals/stats
  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get('/referrals/stats');
    return response.data as Map<String, dynamic>;
  }
}

final referralsServiceProvider = Provider<ReferralsService>((ref) {
  return ReferralsService(ref.watch(dioProvider));
});
