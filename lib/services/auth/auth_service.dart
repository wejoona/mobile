import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';

/// Auth Service - mirrors backend AuthController
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// POST /auth/register
  Future<OtpResponse> register({
    required String phone,
    required String countryCode,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'phone': phone,
        'countryCode': countryCode,
      });
      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/login
  Future<OtpResponse> login({required String phone}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phone': phone,
      });
      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/verify-otp
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
      });
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// OTP Response DTO
class OtpResponse {
  final bool success;
  final String message;
  final int expiresIn;

  const OtpResponse({
    required this.success,
    required this.message,
    required this.expiresIn,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'OTP sent',
      expiresIn: json['expiresIn'] as int? ?? 300,
    );
  }
}

/// Auth Response DTO
class AuthResponse {
  final String accessToken;
  final User user;
  final bool walletCreated;

  const AuthResponse({
    required this.accessToken,
    required this.user,
    required this.walletCreated,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      walletCreated: json['walletCreated'] as bool? ?? false,
    );
  }
}

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});
