import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Auth Service - mirrors backend AuthController
class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthService(this._dio, this._storage);

  /// POST /auth/register
  Future<OtpResponse> register({
    required String phone,
    required String countryCode,
    bool acceptedTerms = false,
    String? termsVersion,
    String? privacyVersion,
  }) async {
    try {
      final phoneValue = PhoneNumberValue.fromAny(
        phoneNumber: phone,
        countryCode: countryCode,
      );
      final response = await _dio.post(
        '/auth/register',
        data: {
          'phone': phoneValue.apiPhone,
          'countryCode': phoneValue.apiCountryCode,
          'acceptedTerms': acceptedTerms,
          if (termsVersion != null) 'termsVersion': termsVersion,
          if (privacyVersion != null) 'privacyVersion': privacyVersion,
        },
      );
      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/login
  Future<OtpResponse> login({
    required String phone,
    String? countryCode,
  }) async {
    try {
      final phoneValue = PhoneNumberValue.fromAny(
        phoneNumber: phone,
        countryCode: countryCode,
      );
      final response = await _dio.post(
        '/auth/login',
        data: {
          'phone': phoneValue.apiPhone,
          'countryCode': phoneValue.apiCountryCode,
        },
      );
      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/recovery/request-otp
  Future<OtpResponse> requestRecoveryOtp({
    required String phone,
    String? countryCode,
    String scope = 'pin_reset',
  }) async {
    try {
      final phoneValue = PhoneNumberValue.fromAny(
        phoneNumber: phone,
        countryCode: countryCode,
      );
      final response = await _dio.post(
        '/auth/recovery/request-otp',
        data: {
          'phone': phoneValue.apiPhone,
          'countryCode': phoneValue.apiCountryCode,
          'scope': scope,
        },
      );
      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/verify-otp
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
    String? countryCode,
    String? verificationId,
  }) async {
    try {
      final phoneValue = PhoneNumberValue.fromAny(
        phoneNumber: phone,
        countryCode: countryCode,
      );
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'phone': phoneValue.apiPhone,
          'countryCode': phoneValue.apiCountryCode,
          'otp': otp,
          if (verificationId != null) 'verificationId': verificationId,
        },
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/recovery/verify-otp
  Future<RecoveryOtpResponse> verifyRecoveryOtp({
    required String phone,
    required String otp,
    String? countryCode,
    String scope = 'pin_reset',
  }) async {
    try {
      final phoneValue = PhoneNumberValue.fromAny(
        phoneNumber: phone,
        countryCode: countryCode,
      );
      final response = await _dio.post(
        '/auth/recovery/verify-otp',
        data: {
          'phone': phoneValue.apiPhone,
          'countryCode': phoneValue.apiCountryCode,
          'otp': otp,
          'scope': scope,
        },
      );
      return RecoveryOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /auth/logout - Invalidate session on backend
  Future<void> logout({String? accessToken, String? refreshToken}) async {
    final logger = const AppLogger('Auth');
    try {
      final token =
          refreshToken ?? await _storage.read(key: StorageKeys.refreshToken);
      if (token == null || token.isEmpty) {
        return;
      }

      if (accessToken == null || accessToken.isEmpty) {
        final refreshed = await _refreshForLogout(token);
        if (refreshed == null) return;
        await _postLogout(
          accessToken: refreshed.accessToken,
          refreshToken: refreshed.refreshToken ?? token,
        );
        return;
      }

      await _postLogout(accessToken: accessToken, refreshToken: token);
    } on DioException catch (e) {
      if (!_isAuthRejected(e)) {
        logger.error('Backend logout failed', e);
        return;
      }

      final token =
          refreshToken ?? await _storage.read(key: StorageKeys.refreshToken);
      if (token == null || token.isEmpty) return;

      final refreshed = await _refreshForLogout(token);
      if (refreshed == null) return;

      try {
        await _postLogout(
          accessToken: refreshed.accessToken,
          refreshToken: refreshed.refreshToken ?? token,
        );
      } catch (retryError) {
        logger.error('Backend logout retry failed', retryError);
      }
    } catch (e) {
      // Non-critical — we clear local tokens regardless
      logger.error('Backend logout failed', e);
    }
  }

  Future<void> _postLogout({
    required String accessToken,
    required String refreshToken,
  }) {
    return _dio.post(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  Future<RefreshResponse?> _refreshForLogout(String refreshToken) async {
    try {
      return await this.refreshToken(refreshToken: refreshToken);
    } catch (e) {
      const AppLogger(
        'Auth',
      ).warn('Could not refresh token before backend logout', e);
      return null;
    }
  }

  bool _isAuthRejected(DioException e) {
    final statusCode = e.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  /// POST /auth/refresh - Refresh access token using refresh token
  Future<RefreshResponse> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return RefreshResponse.fromJson(response.data);
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
  final String? verificationId;

  const OtpResponse({
    required this.success,
    required this.message,
    required this.expiresIn,
    this.verificationId,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'OTP sent',
      expiresIn: json['expiresIn'] as int? ?? 300,
      verificationId: json['verificationId'] as String?,
    );
  }
}

/// Auth Response DTO
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final User user;
  final bool walletCreated;

  /// API returns: none, pending, documents_pending, verified, rejected.
  final String? kycStatus;
  final int expiresIn; // Access token expiry in seconds

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    required this.walletCreated,
    this.kycStatus,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      walletCreated: json['walletCreated'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String?,
      expiresIn: json['expiresIn'] as int? ?? 900, // Default 15 minutes
    );
  }
}

class RecoveryOtpResponse {
  final String recoveryAccessToken;
  final int expiresIn;
  final String scope;

  const RecoveryOtpResponse({
    required this.recoveryAccessToken,
    required this.expiresIn,
    required this.scope,
  });

  factory RecoveryOtpResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryOtpResponse(
      recoveryAccessToken: json['recoveryAccessToken'] as String,
      expiresIn: json['expiresIn'] as int? ?? 600,
      scope: json['scope'] as String? ?? 'pin_reset',
    );
  }
}

/// Refresh Token Response DTO
class RefreshResponse {
  final String accessToken;
  final String? refreshToken;
  final User? user;
  final int expiresIn; // Access token expiry in seconds

  const RefreshResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
    required this.expiresIn,
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return RefreshResponse(
      accessToken: payload['accessToken'] as String,
      refreshToken: payload['refreshToken'] as String?,
      user: payload['user'] != null
          ? User.fromJson(payload['user'] as Map<String, dynamic>)
          : null,
      expiresIn: payload['expiresIn'] as int? ?? 900, // Default 15 minutes
    );
  }
}

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider), ref.watch(secureStorageProvider));
});
