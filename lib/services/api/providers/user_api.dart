/// User API — profile, PIN, locale, avatar, search, limits
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';

class UserApi {
  UserApi(this._dio);
  final Dio _dio;

  // ── Profile ──

  /// GET /user/profile
  Future<Response> getProfile() => _dio.get('/user/profile');

  /// PUT /user/profile
  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _dio.put('/user/profile', data: data);

  /// POST /user/deactivate
  Future<Response> deactivateAccount() => _dio.post('/user/deactivate');

  /// GET /user/data-export
  Future<Response> exportData() => _dio.get('/user/data-export');

  // ── Avatar ──

  /// POST /user/avatar — upload avatar image
  Future<Response> uploadAvatar(
    File file, {
    required AvatarDeviceFaceCheck faceCheck,
  }) async {
    final formData = FormData.fromMap({
      avatarDeviceFaceCheckField: faceCheck.token,
      'avatar': await avatarMultipartFile(file),
    });
    return _dio.post('/user/avatar', data: formData);
  }

  /// DELETE /user/avatar
  Future<Response> deleteAvatar() => _dio.delete('/user/avatar');

  // ── Email Verification ──

  /// POST /user/verify-email
  Future<Response> verifyEmail(String code) =>
      _dio.post('/user/verify-email', data: {'code': code});

  /// GET /user/email-status
  Future<Response> getEmailStatus() => _dio.get('/user/email-status');

  /// POST /user/resend-email-verification
  Future<Response> resendEmailVerification() =>
      _dio.post('/user/resend-email-verification');

  // ── Locale ──

  /// PUT /user/locale
  Future<Response> setLocale(String locale) =>
      _dio.put('/user/locale', data: {'locale': locale});

  // ── PIN ──

  /// POST /user/pin/set
  Future<Response> setPin(String pinHash) =>
      _dio.post('/user/pin/set', data: {'pinHash': pinHash});

  /// POST /user/pin/verify
  Future<Response> verifyPin(String pinHash) =>
      _dio.post('/user/pin/verify', data: {'pinHash': pinHash});

  /// POST /user/pin/change
  Future<Response> changePin({
    required String oldPinHash,
    required String newPinHash,
  }) => _dio.post(
    '/user/pin/change',
    data: {'oldPinHash': oldPinHash, 'newPinHash': newPinHash},
  );

  /// POST /user/pin/reset
  Future<Response> resetPin({
    required String otp,
    required String newPinHash,
    required String stepUpChallengeToken,
  }) => _dio.post(
    '/user/pin/reset',
    data: {
      'otp': otp,
      'newPinHash': newPinHash,
      'stepUpChallengeToken': stepUpChallengeToken,
    },
  );

  // ── Search ──

  /// GET /user/search?q=...
  Future<Response> search(String query) =>
      _dio.get('/user/search', queryParameters: {'q': query});

  /// GET /user/username/check/:username
  Future<Response> checkUsername(String username) =>
      _dio.get('/user/username/check/$username');

  /// GET /user/username/search?q=...
  Future<Response> searchByUsername(String query) =>
      _dio.get('/user/username/search', queryParameters: {'q': query});

  /// GET /user/by-username/:username
  Future<Response> getByUsername(String username) =>
      _dio.get('/user/by-username/$username');

  // ── Limits ──

  /// GET /user/limits
  Future<Response> getLimits() => _dio.get(ApiEndpoints.limits);
}
