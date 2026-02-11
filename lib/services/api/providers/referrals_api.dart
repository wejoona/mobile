/// Referrals API — code, list, leaderboard
library;

import 'package:dio/dio.dart';

class ReferralsApi {
  ReferralsApi(this._dio);
  final Dio _dio;

  /// GET /referrals
  Future<Response> list() => _dio.get('/referrals');

  /// GET /referrals/code — get my referral code
  Future<Response> getCode() => _dio.get('/referrals/code');

  /// GET /referrals/leaderboard
  Future<Response> leaderboard() => _dio.get('/referrals/leaderboard');
}
