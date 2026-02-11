/// Request DTO for updating user profile.
class UpdateProfileRequest {
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final String? preferredCurrency;
  final String? language;
  final String? timezone;

  const UpdateProfileRequest({
    this.displayName,
    this.email,
    this.avatarUrl,
    this.preferredCurrency,
    this.language,
    this.timezone,
  });

  Map<String, dynamic> toJson() => {
        if (displayName != null) 'displayName': displayName,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
        if (language != null) 'language': language,
        if (timezone != null) 'timezone': timezone,
      };
}
