import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';

/// User Service - mirrors backend UserController
class UserService {
  final Dio _dio;

  UserService(this._dio);

  /// GET /user/profile
  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return UserProfile.fromJson(_readPayload(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /user/profile
  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final response = await _dio.put(
        '/user/profile',
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (email != null) 'email': email,
        },
      );
      return UserProfile.fromJson(_readPayload(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /user/avatar - Upload avatar image
  Future<AvatarUploadResult> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await avatarMultipartFile(File(filePath)),
      });

      final response = await _dio.post('/user/avatar', data: formData);
      return AvatarUploadResult.fromJson(_readPayload(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /user/avatar - Remove avatar
  Future<void> removeAvatar() async {
    try {
      await _dio.delete('/user/avatar');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Current avatar URL from the profile payload.
  Future<String?> getAvatarUrl() async {
    final profile = await getProfile();
    return profile.avatarUrl;
  }

  /// POST /user/verify-email — verify email with OTP code
  Future<void> verifyEmail(String code) async {
    try {
      await _dio.post('/user/verify-email', data: {'code': code});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /user/email-status — check email verification status
  Future<Map<String, dynamic>> getEmailStatus() async {
    try {
      final response = await _dio.get('/user/email-status');
      return _readPayload(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /user/resend-email-verification — generate and send a fresh code.
  Future<EmailVerificationResendResult> resendEmailVerification() async {
    try {
      final response = await _dio.post('/user/resend-email-verification');
      return EmailVerificationResendResult.fromJson(
        _readPayload(response.data),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /user/locale - Update preferred locale
  Future<void> updateLocale(String locale) async {
    try {
      await _dio.put('/user/locale', data: {'locale': locale});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// User Profile DTO
class UserProfile {
  final String id;
  final String phone;
  final bool phoneVerified;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool emailVerified;
  final String? avatarUrl;
  final String? avatarThumb;
  final String preferredLocale;
  final String countryCode;
  final String kycStatus;
  final String? kycRejectionReason;
  final bool canTransact;
  final bool canWithdraw;
  final bool hasPin;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    required this.phoneVerified,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerified = false,
    this.avatarUrl,
    this.avatarThumb,
    this.preferredLocale = 'fr',
    required this.countryCode,
    required this.kycStatus,
    this.kycRejectionReason,
    this.canTransact = false,
    this.canWithdraw = false,
    this.hasPin = false,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return phone;
  }

  bool get isKycVerified => kycStatus == 'verified';
  bool get isKycPending => kycStatus == 'pending';
  bool get needsKyc => kycStatus == 'none' || kycStatus == 'not_started';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? json['userId'] ?? json['user_id'] ?? '') as String,
      phone: json['phone'] as String? ?? '',
      phoneVerified:
          _readBool(json, const ['phoneVerified', 'phone_verified']) ?? false,
      username: json['username'] as String?,
      firstName: (json['firstName'] ?? json['first_name']) as String?,
      lastName: (json['lastName'] ?? json['last_name']) as String?,
      email: json['email'] as String?,
      emailVerified:
          _readBool(json, const ['emailVerified', 'email_verified']) ?? false,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      avatarThumb:
          (json['avatarThumb'] ?? json['avatar_thumb'] ?? json['avatarBase64'])
              as String?,
      preferredLocale:
          (json['preferredLocale'] ?? json['preferred_locale']) as String? ??
          'fr',
      countryCode:
          (json['countryCode'] ?? json['country_code']) as String? ?? 'CI',
      kycStatus: (json['kycStatus'] ?? json['kyc_status']) as String? ?? 'none',
      kycRejectionReason:
          (json['kycRejectionReason'] ?? json['kyc_rejection_reason'])
              as String?,
      canTransact:
          _readBool(json, const ['canTransact', 'can_transact']) ?? false,
      canWithdraw:
          _readBool(json, const ['canWithdraw', 'can_withdraw']) ?? false,
      hasPin: _readBool(json, const ['hasPin', 'has_pin']) ?? false,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      createdAt:
          _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'phoneVerified': phoneVerified,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'emailVerified': emailVerified,
    'avatarUrl': avatarUrl,
    'avatarThumb': avatarThumb,
    'preferredLocale': preferredLocale,
    'countryCode': countryCode,
    'kycStatus': kycStatus,
    'kycRejectionReason': kycRejectionReason,
    'canTransact': canTransact,
    'canWithdraw': canWithdraw,
    'hasPin': hasPin,
    'role': role,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

DateTime? _parseDate(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

class AvatarUploadResult {
  final String? avatarUrl;
  final String? avatarThumb;
  final String? message;

  const AvatarUploadResult({this.avatarUrl, this.avatarThumb, this.message});

  factory AvatarUploadResult.fromJson(Map<String, dynamic> json) {
    return AvatarUploadResult(
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      avatarThumb:
          (json['avatarThumb'] ?? json['avatar_thumb'] ?? json['avatarBase64'])
              as String?,
      message: json['message'] as String?,
    );
  }
}

class EmailVerificationResendResult {
  final bool sent;
  final String? email;
  final bool pendingVerification;
  final int expiresIn;
  final String? message;
  final String? debugCode;

  const EmailVerificationResendResult({
    required this.sent,
    required this.pendingVerification,
    required this.expiresIn,
    this.email,
    this.message,
    this.debugCode,
  });

  factory EmailVerificationResendResult.fromJson(Map<String, dynamic> json) {
    return EmailVerificationResendResult(
      sent: json['sent'] as bool? ?? true,
      email: json['email'] as String?,
      pendingVerification: json['pendingVerification'] as bool? ?? true,
      expiresIn: json['expiresIn'] as int? ?? 1800,
      message: json['message'] as String?,
      debugCode: json['debugCode'] as String?,
    );
  }
}

Map<String, dynamic> _readPayload(Object? raw) {
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    final user = map['user'];
    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }
    return map;
  }
  return const {};
}

bool? _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }
  return null;
}

/// User Service Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioProvider));
});
