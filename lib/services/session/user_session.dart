import 'dart:convert';

/// Persistent user session stored in secure storage.
/// This is the "source of truth" for whether a user is logged in,
/// independent of JWT token validity.
class UserSession {
  final String userId;
  final String phoneNumber;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? countryCode;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiresAt;
  final DateTime lastActive;
  final DateTime sessionCreatedAt;
  final bool hasCompletedKyc;
  final String? kycStatus;
  final bool biometricEnabled;
  final String? walletId;
  final String? avatarUrl;

  const UserSession({
    required this.userId,
    required this.phoneNumber,
    this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    this.countryCode,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.lastActive,
    required this.sessionCreatedAt,
    this.hasCompletedKyc = false,
    this.kycStatus,
    this.biometricEnabled = false,
    this.walletId,
    this.avatarUrl,
  });

  /// Session is considered expired after 30 days of inactivity.
  static const sessionMaxAge = Duration(days: 30);

  /// Whether the access token has expired.
  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiresAt);

  /// Whether the session itself is still valid (within 30-day window).
  bool get isSessionValid =>
      DateTime.now().difference(lastActive) < sessionMaxAge;

  /// Whether we have a refresh token to attempt token renewal.
  bool get canRefresh => refreshToken.isNotEmpty;

  UserSession copyWith({
    String? userId,
    String? phoneNumber,
    String? displayName,
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    DateTime? lastActive,
    DateTime? sessionCreatedAt,
    bool? hasCompletedKyc,
    String? kycStatus,
    bool? biometricEnabled,
    String? walletId,
    String? avatarUrl,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      lastActive: lastActive ?? this.lastActive,
      sessionCreatedAt: sessionCreatedAt ?? this.sessionCreatedAt,
      hasCompletedKyc: hasCompletedKyc ?? this.hasCompletedKyc,
      kycStatus: kycStatus ?? this.kycStatus,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      walletId: walletId ?? this.walletId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'countryCode': countryCode,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiresAt': tokenExpiresAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'sessionCreatedAt': sessionCreatedAt.toIso8601String(),
      'hasCompletedKyc': hasCompletedKyc,
      'kycStatus': kycStatus,
      'biometricEnabled': biometricEnabled,
      'walletId': walletId,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      displayName: json['displayName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      countryCode: json['countryCode'] as String?,
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenExpiresAt: DateTime.tryParse(json['tokenExpiresAt'] as String? ?? '') ?? DateTime.now(),
      lastActive: DateTime.tryParse(json['lastActive'] as String? ?? '') ?? DateTime.now(),
      sessionCreatedAt: DateTime.tryParse(json['sessionCreatedAt'] as String? ?? '') ?? DateTime.now(),
      hasCompletedKyc: json['hasCompletedKyc'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String?,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      walletId: json['walletId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static UserSession? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return UserSession.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'UserSession(userId: $userId, phone: $phoneNumber, tokenExpired: $isTokenExpired, sessionValid: $isSessionValid)';
}
