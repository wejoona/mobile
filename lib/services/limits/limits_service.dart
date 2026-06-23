import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Limits Service - mirrors backend user limits endpoints
class LimitsService {
  LimitsService(this._dio);

  final Dio _dio;

  /// GET /user/limits
  Future<TransactionLimits> getLimits() async {
    final response = await _dio.get(ApiEndpoints.limits);
    return TransactionLimits.fromJson(_readPayload(response.data));
  }

  /// GET /user/limits/usage
  Future<LimitUsage> getUsage() async {
    final response = await _dio.get(ApiEndpoints.limitsUsage);
    return LimitUsage.fromJson(_readPayload(response.data));
  }
}

/// Period-specific limit usage data.
class LimitUsage {
  const LimitUsage({
    required this.resetAt,
    this.dailyUsed = 0,
    this.weeklyUsed = 0,
    this.monthlyUsed = 0,
  });

  factory LimitUsage.fromJson(Map<String, dynamic> json) => LimitUsage(
    resetAt: DateTime.parse(
      json['resetAt'] as String? ?? DateTime.now().toIso8601String(),
    ),
    dailyUsed: (json['dailyUsed'] as num?)?.toDouble() ?? 0,
    weeklyUsed: (json['weeklyUsed'] as num?)?.toDouble() ?? 0,
    monthlyUsed: (json['monthlyUsed'] as num?)?.toDouble() ?? 0,
  );

  final double dailyUsed;
  final double weeklyUsed;
  final double monthlyUsed;
  final DateTime resetAt;
}

final limitsServiceProvider = Provider<LimitsService>(
  (ref) => LimitsService(ref.watch(dioProvider)),
);

Map<String, dynamic> _readPayload(Object? raw) {
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return map;
  }
  return const {};
}
