/// User API — profile, PIN, locale, avatar, search, limits
library;

import 'dart:io';
import 'package:dio/dio.dart';

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
  Future<Response> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
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

  // ── Locale ──

  /// PUT /user/locale
  Future<Response> setLocale(String locale) =>
      _dio.put('/user/locale', data: {'locale': locale});

  // ── PIN ──

  /// POST /user/pin/set
  Future<Response> setPin(String pin) =>
      _dio.post('/user/pin/set', data: {'pin': pin});

  /// POST /user/pin/verify
  Future<Response> verifyPin(String pin) =>
      _dio.post('/user/pin/verify', data: {'pin': pin});

  /// POST /user/pin/change
  Future<Response> changePin({
    required String currentPin,
    required String newPin,
  }) =>
      _dio.post('/user/pin/change', data: {
        'currentPin': currentPin,
        'newPin': newPin,
      });

  /// POST /user/pin/reset
  Future<Response> resetPin() => _dio.post('/user/pin/reset');

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
  Future<Response> getLimits() => _dio.get('/user/limits');
}
