import 'package:usdc_wallet/domain/enums/index.dart';

/// User entity - mirrors backend User domain entity
class User {
  final String id;
  final String phone;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;

  /// Avatar stocké en base64 depuis la base de données (pas depuis le bucket S3)
  final String? avatarBase64;
  final String preferredLocale;
  final String countryCode;
  final bool isPhoneVerified;
  final UserRole role;
  final UserStatus status;
  final bool hasPin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.phone,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.avatarBase64,
    this.preferredLocale = 'fr',
    required this.countryCode,
    required this.isPhoneVerified,
    required this.role,
    required this.status,
    this.hasPin = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns @username if set
  String? get usernameDisplay => username != null ? '@$username' : null;

  String get fullName {
    if (firstName == null && lastName == null) return '';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Profile completion percentage (0.0 - 1.0)
  double get profileCompletion {
    int total = 6;
    int completed = 0;
    if (firstName != null && firstName!.isNotEmpty) completed++;
    if (lastName != null && lastName!.isNotEmpty) completed++;
    if (email != null && email!.isNotEmpty) completed++;
    if (username != null && username!.isNotEmpty) completed++;
    if (_hasAvatar) completed++;
    if (hasPin) completed++;
    return completed / total;
  }

  /// Vérifie si l'utilisateur a un avatar (base64 ou URL)
  bool get _hasAvatar =>
      (avatarBase64 != null && avatarBase64!.isNotEmpty) ||
      (avatarUrl != null && avatarUrl!.isNotEmpty);

  /// List of missing profile fields
  List<String> get missingProfileFields {
    final missing = <String>[];
    if (firstName == null || firstName!.isEmpty) missing.add('First name');
    if (lastName == null || lastName!.isEmpty) missing.add('Last name');
    if (email == null || email!.isEmpty) missing.add('Email');
    if (username == null || username!.isEmpty) missing.add('Username');
    if (!_hasAvatar) missing.add('Profile photo');
    if (!hasPin) missing.add('PIN');
    return missing;
  }

  String get displayName {
    if (username != null) return '@$username';
    if (fullName.isNotEmpty) return fullName;
    return phone;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      avatarBase64:
          (json['avatarBase64'] ??
                  json['avatar_base64'] ??
                  json['avatarThumb'] ??
                  json['avatar_thumb'])
              as String?,
      preferredLocale: json['preferredLocale'] as String? ?? 'fr',
      countryCode: json['countryCode'] as String? ?? 'CI',
      // Backend returns 'phoneVerified', handle both keys
      isPhoneVerified:
          (json['phoneVerified'] ?? json['isPhoneVerified']) as bool? ?? false,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      hasPin: _readBool(json, const ['hasPin', 'has_pin']) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatarUrl': avatarUrl,
      'avatarBase64': avatarBase64,
      'preferredLocale': preferredLocale,
      'countryCode': countryCode,
      'isPhoneVerified': isPhoneVerified,
      'role': role.name,
      'status': status.name,
      'hasPin': hasPin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? phone,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? avatarBase64,
    String? preferredLocale,
    String? countryCode,
    bool? isPhoneVerified,
    UserRole? role,
    UserStatus? status,
    bool? hasPin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearAvatarUrl = false,
    bool clearAvatarBase64 = false,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
      avatarBase64: clearAvatarBase64
          ? null
          : avatarBase64 ?? this.avatarBase64,
      preferredLocale: preferredLocale ?? this.preferredLocale,
      countryCode: countryCode ?? this.countryCode,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      role: role ?? this.role,
      status: status ?? this.status,
      hasPin: hasPin ?? this.hasPin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

bool? _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (!json.containsKey(key)) {
      continue;
    }
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
  }
  return null;
}
