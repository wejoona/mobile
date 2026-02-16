import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';

/// Limits Service - mirrors backend user limits endpoints
class LimitsService {
  final Dio _dio;

  LimitsService(this._dio);

  /// GET /user/limits
  Future<TransactionLimits> getLimits() async {
    final response = await _dio.get('/user/limits');
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      // Could be {data: {...}} or direct
      final data = raw.containsKey('data') && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw;
      return TransactionLimits.fromJson(data);
    }
    // Fallback defaults
    return TransactionLimits.fromJson(<String, dynamic>{});
  }

  /// GET /user/limits/usage
  Future<LimitUsage> getUsage() async {
    final response = await _dio.get('/user/limits/usage');
    return LimitUsage.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Period-specific limit usage data.
class LimitUsage {
  final double dailyUsed;
  final double weeklyUsed;
  final double monthlyUsed;
  final DateTime resetAt;

  const LimitUsage({
    this.dailyUsed = 0,
    this.weeklyUsed = 0,
    this.monthlyUsed = 0,
    required this.resetAt,
  });

  factory LimitUsage.fromJson(Map<String, dynamic> json) {
    return LimitUsage(
      dailyUsed: (json['dailyUsed'] as num?)?.toDouble() ?? 0,
      weeklyUsed: (json['weeklyUsed'] as num?)?.toDouble() ?? 0,
      monthlyUsed: (json['monthlyUsed'] as num?)?.toDouble() ?? 0,
      resetAt: DateTime.parse(json['resetAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

final limitsServiceProvider = Provider<LimitsService>((ref) {
  return LimitsService(ref.watch(dioProvider));
});
