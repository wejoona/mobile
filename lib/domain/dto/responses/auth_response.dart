/// Response DTO for authentication.
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final int expiresIn;
  final bool isNewUser;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.expiresIn,
    this.isNewUser = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
      expiresIn: json['expiresIn'] as int? ?? 3600,
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}
