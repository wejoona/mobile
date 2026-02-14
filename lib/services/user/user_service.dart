import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// User Service - mirrors backend UserController
class UserService {
  final Dio _dio;

  UserService(this._dio);

  /// GET /user/profile
  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return UserProfile.fromJson(response.data);
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
      final response = await _dio.put('/user/profile', data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
      });
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /user/avatar - Upload avatar image
  /// Returns the updated user profile with new avatarUrl
  Future<UserProfile> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('/user/avatar', data: formData);
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /user/avatar - Remove avatar
  Future<UserProfile> removeAvatar() async {
    try {
      final response = await _dio.delete('/user/avatar');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /user/avatar - Get current avatar URL
  Future<String?> getAvatarUrl() async {
    try {
      final response = await _dio.get('/user/avatar');
      return response.data['avatarUrl'] as String?;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /user/locale - Update preferred locale
  Future<void> updateLocale(String locale) async {
    try {
      await _dio.put('/user/locale', data: {'preferredLocale': locale});
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
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final String countryCode;
  final String kycStatus;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    required this.phoneVerified,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    required this.countryCode,
    required this.kycStatus,
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
      id: json['id'] as String,
      phone: json['phone'] as String,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      countryCode: json['countryCode'] as String? ?? 'CI',
      kycStatus: json['kycStatus'] as String? ?? 'none',
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'phone': phone, 'phoneVerified': phoneVerified,
    'firstName': firstName, 'lastName': lastName, 'email': email,
    'avatarUrl': avatarUrl, 'countryCode': countryCode,
    'kycStatus': kycStatus, 'role': role, 'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

/// User Service Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioProvider));
});
