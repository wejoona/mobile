/// Auth API — register, login, OTP, token refresh, logout
library;

import 'package:dio/dio.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  /// POST /auth/register
  Future<Response> register({
    required String phone,
    String countryCode = 'CI',
  }) => _dio.post(
    '/auth/register',
    data: {'phone': phone, 'countryCode': countryCode},
  );

  /// POST /auth/login — sends OTP to phone
  Future<Response> login({required String phone}) =>
      _dio.post('/auth/login', data: {'phone': phone});

  /// POST /auth/verify-otp — returns access + refresh tokens
  Future<Response> verifyOtp({required String phone, required String otp}) =>
      _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});

  /// POST /auth/refresh — refresh the access token
  Future<Response> refreshToken({required String refreshToken}) =>
      _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});

  /// POST /auth/logout
  Future<Response> logout() => _dio.post('/auth/logout');

  /// POST /auth/logout-all — invalidate all sessions
  Future<Response> logoutAll() =>
      _dio.post('/auth/logout-all', data: const <String, dynamic>{});
}
