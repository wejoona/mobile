import '../enums/index.dart';

/// User entity - mirrors backend User domain entity
class User {
  final String id;
  final String phone;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
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
    if (avatarUrl != null && avatarUrl!.isNotEmpty) completed++;
    if (hasPin) completed++;
    return completed / total;
  }

  /// List of missing profile fields
  List<String> get missingProfileFields {
    final missing = <String>[];
    if (firstName == null || firstName!.isEmpty) missing.add('First name');
    if (lastName == null || lastName!.isEmpty) missing.add('Last name');
    if (email == null || email!.isEmpty) missing.add('Email');
    if (username == null || username!.isEmpty) missing.add('Username');
    if (avatarUrl == null || avatarUrl!.isEmpty) missing.add('Profile photo');
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
      avatarUrl: json['avatarUrl'] as String?,
      preferredLocale: json['preferredLocale'] as String? ?? 'fr',
      countryCode: json['countryCode'] as String? ?? 'CI',
      // Backend returns 'phoneVerified', handle both keys
      isPhoneVerified: (json['phoneVerified'] ?? json['isPhoneVerified']) as bool? ?? false,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      hasPin: json['hasPin'] as bool? ?? false,
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
    String? preferredLocale,
    String? countryCode,
    bool? isPhoneVerified,
    UserRole? role,
    UserStatus? status,
    bool? hasPin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
