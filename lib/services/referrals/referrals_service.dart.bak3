import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';

/// Referrals Service - mirrors backend ReferralsController
class ReferralsService {
  final Dio _dio;

  ReferralsService(this._dio);

  /// GET /referrals/code
  Future<String> getReferralCode() async {
    try {
      final response = await _dio.get('/referrals/code');
      return response.data['code'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /referrals/stats
  Future<ReferralStats> getStats() async {
    try {
      final response = await _dio.get('/referrals/stats');
      return ReferralStats.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /referrals/history
  Future<List<Referral>> getHistory() async {
    try {
      final response = await _dio.get('/referrals/history');
      final List<dynamic> data = response.data ?? [];
      return data
          .map((e) => Referral.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /referrals/apply
  Future<ApplyReferralResponse> applyReferralCode(String code) async {
    try {
      final response = await _dio.post('/referrals/apply', data: {
        'code': code,
      });
      return ApplyReferralResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /referrals/leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _dio.get('/referrals/leaderboard');
      final List<dynamic> data = response.data ?? [];
      return data
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Apply Referral Response
class ApplyReferralResponse {
  final bool success;
  final String message;

  const ApplyReferralResponse({
    required this.success,
    required this.message,
  });

  factory ApplyReferralResponse.fromJson(Map<String, dynamic> json) {
    return ApplyReferralResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Referral code applied',
    );
  }
}

/// Leaderboard Entry
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final int referralCount;
  final double totalEarnings;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.referralCount,
    required this.totalEarnings,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? 'Anonymous',
      referralCount: json['referralCount'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Referrals Service Provider
final referralsServiceProvider = Provider<ReferralsService>((ref) {
  return ReferralsService(ref.watch(dioProvider));
});
